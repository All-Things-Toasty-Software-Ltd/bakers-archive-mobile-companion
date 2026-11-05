import 'package:flutter/foundation.dart';
import '../data/models/recipe_detail.dart';
import '../data/models/recipe_summary.dart';
import '../data/services/storage_service.dart';

/// Provider managing locally stored offline favorites without requiring any account.
class FavoritesProvider extends ChangeNotifier {
  final StorageService _storageService;

  FavoritesProvider(this._storageService) {
    loadFavorites();
  }

  List<RecipeSummary> _favorites = [];
  Set<int> _favoriteIds = {};

  List<RecipeSummary> get favorites => _favorites;
  Set<int> get favoriteIds => _favoriteIds;

  void loadFavorites() {
    _favoriteIds = _storageService.getFavoriteIds().toSet();
    _favorites = _storageService.getAllOfflineFavoriteSummaries();
    notifyListeners();
  }

  bool isFavorite(int recipeId) {
    return _favoriteIds.contains(recipeId);
  }

  Future<bool> toggleFavorite(RecipeDetail recipe) async {
    final isFav = isFavorite(recipe.id);
    if (isFav) {
      await _storageService.removeFavoriteRecipe(recipe.id);
      _favoriteIds.remove(recipe.id);
      _favorites.removeWhere((r) => r.id == recipe.id);
    } else {
      await _storageService.saveFavoriteRecipe(recipe);
      _favoriteIds.add(recipe.id);
      _favorites.insert(
        0,
        RecipeSummary(
          id: recipe.id,
          name: recipe.name,
          teaser: recipe.teaser.isNotEmpty ? recipe.teaser : recipe.description,
          publishedDate: recipe.publishedDate,
          archiveId: recipe.archiveId,
          archiveName: recipe.archiveName,
          coverImageUrl: recipe.mainImageUrl,
        ),
      );
    }
    notifyListeners();
    return !isFav;
  }

  Future<void> removeFavorite(int recipeId) async {
    await _storageService.removeFavoriteRecipe(recipeId);
    _favoriteIds.remove(recipeId);
    _favorites.removeWhere((r) => r.id == recipeId);
    notifyListeners();
  }
}
