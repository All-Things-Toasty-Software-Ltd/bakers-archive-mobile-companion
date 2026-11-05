import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/recipe_detail.dart';
import '../models/recipe_summary.dart';
import '../models/odoo_user.dart';

/// Local persistence manager for server settings, offline favorites, and sessions.
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- Server & Database ---

  String getServerUrl() {
    return _prefs.getString(AppConstants.prefServerUrl) ?? AppConstants.defaultServerUrl;
  }

  Future<bool> setServerUrl(String url) {
    var cleanUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'https://$cleanUrl';
    }
    return _prefs.setString(AppConstants.prefServerUrl, cleanUrl);
  }

  String? getDatabase() {
    return _prefs.getString(AppConstants.prefDatabase);
  }

  Future<bool> setDatabase(String db) {
    return _prefs.setString(AppConstants.prefDatabase, db.trim());
  }

  // --- Theme Mode ---

  String getThemeMode() {
    return _prefs.getString(AppConstants.prefThemeMode) ?? 'warm_crust'; // default light
  }

  Future<bool> setThemeMode(String mode) {
    return _prefs.setString(AppConstants.prefThemeMode, mode);
  }

  // --- Authenticated User Session ---

  OdooUser? getUserSession() {
    final raw = _prefs.getString(AppConstants.prefUserSession);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return OdooUser.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveUserSession(OdooUser user) {
    final raw = jsonEncode(user.toJson());
    return _prefs.setString(AppConstants.prefUserSession, raw);
  }

  Future<bool> clearUserSession() {
    return _prefs.remove(AppConstants.prefUserSession);
  }

  // --- Offline Favorites Management ---

  List<int> getFavoriteIds() {
    final list = _prefs.getStringList(AppConstants.prefFavorites) ?? [];
    return list.map((e) => int.tryParse(e)).whereType<int>().toList();
  }

  bool isFavorite(int recipeId) {
    final list = _prefs.getStringList(AppConstants.prefFavorites) ?? [];
    return list.contains(recipeId.toString());
  }

  Future<bool> saveFavoriteRecipe(RecipeDetail recipe) async {
    final list = _prefs.getStringList(AppConstants.prefFavorites) ?? [];
    final idStr = recipe.id.toString();

    if (!list.contains(idStr)) {
      list.insert(0, idStr);
      await _prefs.setStringList(AppConstants.prefFavorites, list);
    }

    // Cache the full recipe detail JSON for offline viewing
    final jsonStr = jsonEncode(recipe.toJson());
    await _prefs.setString('${AppConstants.prefFavoritesData}_$idStr', jsonStr);
    return true;
  }

  Future<bool> removeFavoriteRecipe(int recipeId) async {
    final list = _prefs.getStringList(AppConstants.prefFavorites) ?? [];
    final idStr = recipeId.toString();

    list.remove(idStr);
    await _prefs.setStringList(AppConstants.prefFavorites, list);
    await _prefs.remove('${AppConstants.prefFavoritesData}_$idStr');
    return true;
  }

  RecipeDetail? getOfflineRecipeDetail(int recipeId) {
    final raw = _prefs.getString('${AppConstants.prefFavoritesData}_$recipeId');
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return RecipeDetail.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  List<RecipeSummary> getAllOfflineFavoriteSummaries() {
    final ids = getFavoriteIds();
    final List<RecipeSummary> summaries = [];

    for (final id in ids) {
      final detail = getOfflineRecipeDetail(id);
      if (detail != null) {
        summaries.add(RecipeSummary(
          id: detail.id,
          name: detail.name,
          teaser: detail.teaser.isNotEmpty ? detail.teaser : detail.description,
          publishedDate: detail.publishedDate,
          archiveId: detail.archiveId,
          archiveName: detail.archiveName,
          coverImageUrl: detail.mainImageUrl,
        ));
      }
    }

    return summaries;
  }
}
