import 'package:flutter/foundation.dart';
import '../data/models/archive_model.dart';
import '../data/models/recipe_summary.dart';
import '../data/services/bakers_api_service.dart';

/// Provider managing archive list, active archive filter, recipe summaries, and search.
class ArchiveProvider extends ChangeNotifier {
  final BakersApiService _apiService;

  ArchiveProvider({BakersApiService? apiService})
      : _apiService = apiService ?? BakersApiService();

  List<ArchiveModel> _archives = [];
  ArchiveModel? _selectedArchive;
  List<RecipeSummary> _recipes = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<ArchiveModel> get archives => _archives;
  ArchiveModel? get selectedArchive => _selectedArchive;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  /// Filtered recipes based on search query
  List<RecipeSummary> get filteredRecipes {
    if (_searchQuery.trim().isEmpty) {
      return _recipes;
    }
    final q = _searchQuery.toLowerCase().trim();
    return _recipes.where((r) {
      final nameMatch = r.name.toLowerCase().contains(q);
      final teaserMatch = r.teaser.toLowerCase().contains(q);
      final archiveMatch = (r.archiveName ?? '').toLowerCase().contains(q);
      return nameMatch || teaserMatch || archiveMatch;
    }).toList();
  }

  /// Initial load or server URL change
  Future<void> init(String baseUrl) async {
    await loadArchives(baseUrl);
  }

  /// Fetch all archives and load the initial recipes
  Future<void> loadArchives(String baseUrl) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _archives = await _apiService.fetchArchives(baseUrl);
      _selectedArchive = null; // Default to "All Archives"
      await _loadRecipesForSelection(baseUrl);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      _recipes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Select an archive or null for "All Archives"
  Future<void> selectArchive(ArchiveModel? archive, String baseUrl) async {
    if (_selectedArchive == archive) return;
    _selectedArchive = archive;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loadRecipesForSelection(baseUrl);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update live search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Clear active search query
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Refresh current data
  Future<void> refresh(String baseUrl) async {
    try {
      _archives = await _apiService.fetchArchives(baseUrl);
      await _loadRecipesForSelection(baseUrl);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
    } finally {
      notifyListeners();
    }
  }

  /// Helper to load recipes depending on whether an archive is selected or "All"
  Future<void> _loadRecipesForSelection(String baseUrl) async {
    if (_selectedArchive != null) {
      _recipes = await _apiService.fetchArchiveRecipes(
        baseUrl,
        _selectedArchive!.id,
        archiveName: _selectedArchive!.name,
      );
    } else {
      // Load recipes across all archives
      final List<RecipeSummary> all = [];
      final seenIds = <int>{};

      for (final arch in _archives) {
        try {
          final items = await _apiService.fetchArchiveRecipes(
            baseUrl,
            arch.id,
            archiveName: arch.name,
          );
          for (final item in items) {
            if (seenIds.add(item.id)) {
              all.add(item);
            }
          }
        } catch (_) {}
      }
      _recipes = all;
    }
  }
}
