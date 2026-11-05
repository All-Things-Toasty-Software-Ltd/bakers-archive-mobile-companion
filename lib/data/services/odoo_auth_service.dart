import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/odoo_user.dart';

class AuthResult {
  final bool success;
  final String message;
  final OdooUser? user;

  const AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
}

/// Service for authenticating Odoo users on single-database and standard instances.
class OdooAuthService {
  final http.Client _client;

  OdooAuthService({http.Client? client}) : _client = client ?? http.Client();

  /// Authenticate against Odoo with automatic single-database handling
  Future<AuthResult> authenticate({
    required String baseUrl,
    required String login,
    required String password,
    String? database,
  }) async {
    final cleanUrl = baseUrl.replaceAll(RegExp(r'/+$'), '');

    // Step 1: Attempt Web Session Authentication (Works reliably when list_db = False)
    try {
      final webResult = await _authenticateViaWebLogin(
        cleanUrl: cleanUrl,
        login: login,
        password: password,
      );
      if (webResult.success && webResult.user != null) {
        return webResult;
      }
    } catch (_) {
      // Continue to JSON-RPC fallback
    }

    // Step 2: Attempt standard JSON-RPC if database is known or probed
    final String targetDb = (database != null && database.isNotEmpty)
        ? database
        : await _probeDatabaseName(cleanUrl) ?? '';

    if (targetDb.isNotEmpty) {
      try {
        final rpcResult = await _authenticateViaRpc(
          cleanUrl: cleanUrl,
          db: targetDb,
          login: login,
          password: password,
        );
        if (rpcResult.success && rpcResult.user != null) {
          return rpcResult;
        }
      } catch (_) {}
    }

    return const AuthResult(
      success: false,
      message: "Invalid credentials or unable to authenticate with Odoo server.",
    );
  }

  /// Web Login authentication using Odoo web form endpoint
  Future<AuthResult> _authenticateViaWebLogin({
    required String cleanUrl,
    required String login,
    required String password,
  }) async {
    final loginPageUri = Uri.parse('$cleanUrl${AppConstants.odooLogin}');

    // 1. GET login page to get initial session_id and csrf_token
    final getResponse = await _client.get(
      loginPageUri,
      headers: {
        'User-Agent': 'BakersArchiveMobile/1.0',
        'Accept': 'text/html,application/xhtml+xml',
      },
    ).timeout(const Duration(seconds: 10));

    final cookieHeader = _extractCookies(getResponse.headers['set-cookie']);
    final csrfToken = _extractCsrfToken(getResponse.body);

    // 2. POST login form
    final postResponse = await _client.post(
      loginPageUri,
      headers: {
        'User-Agent': 'BakersArchiveMobile/1.0',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Cookie': cookieHeader,
        'Referer': '$cleanUrl${AppConstants.odooLogin}',
      },
      body: {
        'login': login,
        'password': password,
        if (csrfToken != null) 'csrf_token': csrfToken,
        'redirect': '/web',
      },
    ).timeout(const Duration(seconds: 12));

    final combinedCookies = _mergeCookies(
      cookieHeader,
      _extractCookies(postResponse.headers['set-cookie']),
    );

    // 3. Verify session and obtain user information
    final sessionInfoUri = Uri.parse('$cleanUrl${AppConstants.odooSessionInfo}');
    final sessionResp = await _client.post(
      sessionInfoUri,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': combinedCookies,
        'User-Agent': 'BakersArchiveMobile/1.0',
      },
      body: jsonEncode({
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {},
      }),
    ).timeout(const Duration(seconds: 8));

    if (sessionResp.statusCode == 200) {
      final sessionBody = jsonDecode(sessionResp.body);
      final result = sessionBody['result'];

      if (result is Map && result['uid'] != null && result['uid'] != false) {
        final int uid = result['uid'] as int;
        final String name = result['name'] as String? ?? login;
        final String username = result['username'] as String? ?? login;
        final String db = result['db'] as String? ?? '';
        final bool isAdmin = result['is_admin'] as bool? ?? false;
        final bool isSystem = result['is_system'] as bool? ?? false;

        final sessionId = _extractSessionIdValue(combinedCookies);

        final user = OdooUser(
          uid: uid,
          name: name,
          username: username,
          database: db,
          serverUrl: cleanUrl,
          sessionId: sessionId,
          isAdmin: isAdmin || isSystem,
          isInternalUser: result['is_internal_user'] as bool? ?? true,
          avatarUrl: '$cleanUrl/web/image/res.users/$uid/avatar_128',
        );

        return AuthResult(
          success: true,
          message: 'Signed in successfully!',
          user: user,
        );
      }
    }

    return const AuthResult(
      success: false,
      message: "Authentication failed. Please verify your login and password.",
    );
  }

  /// Authenticate via Odoo standard JSON-RPC
  Future<AuthResult> _authenticateViaRpc({
    required String cleanUrl,
    required String db,
    required String login,
    required String password,
  }) async {
    final uri = Uri.parse('$cleanUrl${AppConstants.odooAuthenticate}');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'db': db,
          'login': login,
          'password': password,
        },
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final result = body['result'];

      if (result is Map && result['uid'] != null && result['uid'] != false) {
        final int uid = result['uid'] as int;
        final String name = result['name'] as String? ?? login;
        final String username = result['username'] as String? ?? login;
        final bool isAdmin = result['is_admin'] as bool? ?? false;
        final String sessionId = _extractSessionIdValue(response.headers['set-cookie'] ?? '') ?? '';

        final user = OdooUser(
          uid: uid,
          name: name,
          username: username,
          database: db,
          serverUrl: cleanUrl,
          sessionId: sessionId,
          isAdmin: isAdmin,
          isInternalUser: result['is_internal_user'] as bool? ?? true,
          avatarUrl: '$cleanUrl/web/image/res.users/$uid/avatar_128',
        );

        return AuthResult(
          success: true,
          message: 'Signed in successfully!',
          user: user,
        );
      }
    }

    return const AuthResult(
      success: false,
      message: "JSON-RPC authentication failed.",
    );
  }

  /// Probe for database name from host HTML and cookies
  Future<String?> _probeDatabaseName(String cleanUrl) async {
    try {
      final uri = Uri.parse('$cleanUrl${AppConstants.odooLogin}');
      final response = await _client.get(uri).timeout(const Duration(seconds: 6));

      // 1. Check cookies for last_used_database
      final cookies = response.headers['set-cookie'];
      if (cookies != null) {
        final match = RegExp(r'last_used_database=([^;]+)').firstMatch(cookies);
        if (match != null) return match.group(1)?.trim();

        final matchDb = RegExp(r'db=([^;]+)').firstMatch(cookies);
        if (matchDb != null) return matchDb.group(1)?.trim();
      }

      // 2. Check HTML for odoo.__session_info__
      final body = response.body;
      final sessionMatch = RegExp(r'odoo\.__session_info__\s*=\s*(\{[\s\S]*?\});').firstMatch(body);
      if (sessionMatch != null) {
        final jsonStr = sessionMatch.group(1);
        if (jsonStr != null) {
          final data = jsonDecode(jsonStr);
          if (data is Map && data['db'] is String && (data['db'] as String).isNotEmpty) {
            return data['db'] as String;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  String? _extractCsrfToken(String html) {
    final match = RegExp("name=[\x27\x22]csrf_token[\x27\x22]\\s+value=[\x27\x22]([^\x27\x22]+)[\x27\x22]").firstMatch(html);
    return match?.group(1);
  }

  String _extractCookies(String? setCookie) {
    if (setCookie == null || setCookie.isEmpty) return '';
    final List<String> list = [];
    final parts = setCookie.split(RegExp(r',(?=[^;]+?=)'));
    for (final p in parts) {
      final firstPart = p.split(';')[0].trim();
      if (firstPart.isNotEmpty && firstPart.contains('=')) {
        list.add(firstPart);
      }
    }
    return list.join('; ');
  }

  String _mergeCookies(String current, String newCookies) {
    final Map<String, String> map = {};
    for (final c in current.split(';')) {
      final kv = c.trim().split('=');
      if (kv.length >= 2) map[kv[0].trim()] = kv[1].trim();
    }
    for (final c in newCookies.split(';')) {
      final kv = c.trim().split('=');
      if (kv.length >= 2) map[kv[0].trim()] = kv[1].trim();
    }
    return map.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  String? _extractSessionIdValue(String cookieString) {
    final match = RegExp(r'session_id=([^;]+)').firstMatch(cookieString);
    return match?.group(1)?.trim();
  }
}
