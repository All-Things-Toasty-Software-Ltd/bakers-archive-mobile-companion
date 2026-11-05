import 'package:flutter/foundation.dart';
import '../data/models/odoo_user.dart';
import '../data/services/bakers_api_service.dart';
import '../data/services/odoo_auth_service.dart';
import '../data/services/storage_service.dart';

/// Provider managing server connection, single-database detection, and Odoo authentication.
class AuthProvider extends ChangeNotifier {
  final StorageService _storageService;
  final BakersApiService _apiService;
  final OdooAuthService _authService;

  AuthProvider({
    required StorageService storageService,
    BakersApiService? apiService,
    OdooAuthService? authService,
  })  : _storageService = storageService,
        _apiService = apiService ?? BakersApiService(),
        _authService = authService ?? OdooAuthService() {
    _serverUrl = _storageService.getServerUrl();
    _database = _storageService.getDatabase() ?? '';
    _currentUser = _storageService.getUserSession();
    // Test default server connection on startup
    testConnection();
  }

  late String _serverUrl;
  late String _database;
  OdooUser? _currentUser;

  bool _isTestingConnection = false;
  ServerConnectionResult? _connectionResult;

  bool _isAuthenticating = false;
  String? _authError;

  String get serverUrl => _serverUrl;
  String get database => _database;
  OdooUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  bool get isTestingConnection => _isTestingConnection;
  ServerConnectionResult? get connectionResult => _connectionResult;

  bool get isAuthenticating => _isAuthenticating;
  String? get authError => _authError;

  /// Test server reachability and Baker's Archive API presence
  Future<ServerConnectionResult> testConnection([String? customUrl]) async {
    _isTestingConnection = true;
    notifyListeners();

    final target = customUrl ?? _serverUrl;
    final result = await _apiService.testConnection(target);
    _connectionResult = result;
    _isTestingConnection = false;
    notifyListeners();
    return result;
  }

  /// Change server URL with auto-test and persistence
  Future<bool> setServerUrl(String newUrl) async {
    final clean = newUrl.trim().replaceAll(RegExp(r'/+$'), '');
    final withScheme = (clean.startsWith('http://') || clean.startsWith('https://'))
        ? clean
        : 'https://$clean';

    _serverUrl = withScheme;
    await _storageService.setServerUrl(_serverUrl);
    notifyListeners();

    final res = await testConnection();
    return res.success;
  }

  /// Set optional database name override
  Future<void> setDatabase(String db) async {
    _database = db.trim();
    await _storageService.setDatabase(_database);
    notifyListeners();
  }

  /// Sign in as Odoo user or administrator
  Future<bool> signIn(String login, String password) async {
    _isAuthenticating = true;
    _authError = null;
    notifyListeners();

    try {
      final result = await _authService.authenticate(
        baseUrl: _serverUrl,
        login: login,
        password: password,
        database: _database.isNotEmpty ? _database : null,
      );

      if (result.success && result.user != null) {
        _currentUser = result.user;
        await _storageService.saveUserSession(result.user!);
        if (result.user!.database.isNotEmpty) {
          _database = result.user!.database;
          await _storageService.setDatabase(_database);
        }
        _authError = null;
        return true;
      } else {
        _authError = result.message;
        return false;
      }
    } catch (e) {
      _authError = e.toString().replaceAll('Exception:', '').trim();
      return false;
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  /// Sign out and clear stored session
  Future<void> signOut() async {
    _currentUser = null;
    await _storageService.clearUserSession();
    notifyListeners();
  }
}
