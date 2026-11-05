import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/archive_model.dart';
import '../models/recipe_summary.dart';
import '../models/recipe_detail.dart';

class ServerConnectionResult {
  final bool success;
  final bool hasBakersArchive;
  final String message;
  final int? latencyMs;
  final String? serverVersion;

  const ServerConnectionResult({
    required this.success,
    required this.hasBakersArchive,
    required this.message,
    this.latencyMs,
    this.serverVersion,
  });
}

/// Service for communicating with the Baker's Archive REST API.
class BakersApiService {
  final http.Client _client;

  BakersApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Test server connection and determine if Baker's Archive is installed
  Future<ServerConnectionResult> testConnection(String baseUrl) async {
    final cleanUrl = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final stopwatch = Stopwatch()..start();

    try {
      // 1. Check Baker's Archive Public API
      final uri = Uri.parse('$cleanUrl${AppConstants.apiArchivesPath}');
      final response = await _client.get(uri).timeout(const Duration(seconds: 8));
      stopwatch.stop();

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        if (body is Map && body['api_version'] != null) {
          final count = (body['archives'] as List?)?.length ?? 0;
          return ServerConnectionResult(
            success: true,
            hasBakersArchive: true,
            latencyMs: stopwatch.elapsedMilliseconds,
            message: "Connected! Found $count archive${count == 1 ? '' : 's'}.",
          );
        }
      }

      // 2. Fallback check Odoo base server
      final versionUri = Uri.parse('$cleanUrl${AppConstants.odooVersionInfo}');
      final odooResponse = await _client.post(
        versionUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'jsonrpc': '2.0',
          'method': 'call',
          'params': {},
        }),
      ).timeout(const Duration(seconds: 8));

      if (odooResponse.statusCode == 200) {
        final odooBody = jsonDecode(odooResponse.body);
        final version = odooBody['result']?['server_version'] as String?;
        return ServerConnectionResult(
          success: true,
          hasBakersArchive: false,
          serverVersion: version,
          latencyMs: stopwatch.elapsedMilliseconds,
          message: "Odoo server reached (version $version), but Baker's Archive module is not found.",
        );
      }

      return ServerConnectionResult(
        success: false,
        hasBakersArchive: false,
        message: "Server returned HTTP status ${response.statusCode}",
      );
    } catch (e) {
      stopwatch.stop();
      return ServerConnectionResult(
        success: false,
        hasBakersArchive: false,
        message: "Unable to reach server: ${e.toString()}",
      );
    }
  }

  /// Discover all archives on the server
  Future<List<ArchiveModel>> fetchArchives(String baseUrl) async {
    final cleanUrl = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$cleanUrl${AppConstants.apiArchivesPath}');

    final response = await _client.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception("Failed to load archives (HTTP ${response.statusCode})");
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (data is Map && data['archives'] is List) {
      return (data['archives'] as List)
          .map((a) => ArchiveModel.fromJson(a as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Fetch recipes belonging to a specific archive
  Future<List<RecipeSummary>> fetchArchiveRecipes(
    String baseUrl,
    int archiveId, {
    String? archiveName,
    int page = 1,
    int limit = 30,
  }) async {
    final cleanUrl = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$cleanUrl${AppConstants.apiArchivePath}/$archiveId?page=$page&limit=$limit');

    final response = await _client.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception("Failed to load archive recipes (HTTP ${response.statusCode})");
    }

    final body = jsonDecode(utf8.decode(response.bodyBytes));
    final recipesObj = body['recipes'];
    final parentArchiveName = archiveName ?? body['data']?['name'] as String?;

    if (recipesObj is Map && recipesObj['items'] is List) {
      final items = recipesObj['items'] as List;
      return items.map((item) {
        return RecipeSummary.fromJson(
          item as Map<String, dynamic>,
          baseUrl: cleanUrl,
          archiveId: archiveId,
          archiveName: parentArchiveName,
        );
      }).toList();
    }
    return [];
  }

  /// Fetch deep serialized recipe details
  Future<RecipeDetail> fetchRecipeDetail(String baseUrl, int recipeId, {int depth = 3}) async {
    final cleanUrl = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$cleanUrl${AppConstants.apiRecipePath}/$recipeId?depth=$depth');

    final response = await _client.get(uri).timeout(const Duration(seconds: 12));

    if (response.statusCode != 200) {
      throw Exception("Failed to load recipe detail (HTTP ${response.statusCode})");
    }

    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return RecipeDetail.fromOdooApiResponse(body, baseUrl: cleanUrl);
  }
}
