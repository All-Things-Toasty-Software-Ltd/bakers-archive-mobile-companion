import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/theme/bread_colors.dart';
import '../providers/archive_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/archive_chip_list.dart';
import '../widgets/bread_loader.dart';
import '../widgets/recipe_card.dart';
import '../widgets/server_status_badge.dart';
import 'recipe_detail_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';
import '../data/models/recipe_detail.dart';
import '../data/services/bakers_api_service.dart';

/// Main screen with bottom navigation (Explore Feed, Offline Favorites, Settings).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final serverUrl = context.read<AuthProvider>().serverUrl;
      context.read<ArchiveProvider>().init(serverUrl);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildExploreTab(context),
          const FavoritesScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildExploreTab(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final archiveProv = context.watch<ArchiveProvider>();
    final authProv = context.watch<AuthProvider>();
    final favProv = context.watch<FavoritesProvider>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.breadSlice,
              color: BreadColors.crustGoldDark,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              "Baker's Archive",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ServerStatusBadge(
              onTap: () {
                setState(() => _currentIndex = 2); // Switch to settings
              },
            ),
          ),
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.search_off : Icons.search),
            tooltip: 'Search recipes',
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                  archiveProv.clearSearch();
                }
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: BreadColors.crustGoldDark,
        onRefresh: () async {
          await archiveProv.refresh(authProv.serverUrl);
        },
        child: Column(
          children: [
            // Search Bar (Collapsible)
            if (_isSearchVisible)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search recipes, ingredients, tags...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              archiveProv.clearSearch();
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onChanged: (val) {
                    archiveProv.setSearchQuery(val);
                  },
                ),
              ),

            // Archive Horizontal Selector Chips
            if (archiveProv.archives.isNotEmpty)
              ArchiveChipList(
                archives: archiveProv.archives,
                selectedArchive: archiveProv.selectedArchive,
                onSelected: (archive) {
                  archiveProv.selectArchive(archive, authProv.serverUrl);
                },
              ),

            // Main Feed Area
            Expanded(
              child: archiveProv.isLoading && archiveProv.filteredRecipes.isEmpty
                  ? const BreadLoader(message: 'Gathering fresh recipes...')
                  : archiveProv.errorMessage != null && archiveProv.filteredRecipes.isEmpty
                      ? _buildErrorView(context, archiveProv, authProv)
                      : archiveProv.filteredRecipes.isEmpty
                          ? _buildEmptyView(archiveProv, isDark, theme)
                          : _buildRecipeList(context, archiveProv, favProv),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeList(
    BuildContext context,
    ArchiveProvider archiveProv,
    FavoritesProvider favProv,
  ) {
    final recipes = archiveProv.filteredRecipes;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;

        if (isTablet) {
          // 2 columns for tablet or landscape
          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.85,
            ),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              final isFav = favProv.isFavorite(recipe.id);
              return RecipeCard(
                recipe: recipe,
                isFavorite: isFav,
                onTap: () => _openRecipe(context, recipe.id, recipe.name, recipe.coverImageUrl),
                onToggleFavorite: () async {
                  final detail = await _fetchDetailForFav(context, recipe.id);
                  if (detail != null) {
                    favProv.toggleFavorite(detail);
                  }
                },
              );
            },
          );
        }

        // Single column feed for mobile phone (e.g. Pixel 10a)
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            final isFav = favProv.isFavorite(recipe.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: RecipeCard(
                recipe: recipe,
                isFavorite: isFav,
                onTap: () => _openRecipe(context, recipe.id, recipe.name, recipe.coverImageUrl),
                onToggleFavorite: () async {
                  final detail = await _fetchDetailForFav(context, recipe.id);
                  if (detail != null) {
                    favProv.toggleFavorite(detail);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  void _openRecipe(BuildContext context, int recipeId, String recipeName, String? coverUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeDetailScreen(
          recipeId: recipeId,
          recipeName: recipeName,
          initialCoverUrl: coverUrl,
        ),
      ),
    );
  }

  Future<RecipeDetail?> _fetchDetailForFav(BuildContext context, int recipeId) async {
    final serverUrl = context.read<AuthProvider>().serverUrl;
    try {
      final api = BakersApiService();
      return await api.fetchRecipeDetail(serverUrl, recipeId);
    } catch (_) {
      return null;
    }
  }

  Widget _buildEmptyView(ArchiveProvider archiveProv, bool isDark, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.breadSlice,
              size: 48,
              color: BreadColors.crustGold.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 16),
            Text(
              archiveProv.searchQuery.isNotEmpty
                  ? 'No recipes match "${archiveProv.searchQuery}"'
                  : 'No recipes found in this archive',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Pull down to refresh or check another archive collection.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? BreadColors.textLightMuted : BreadColors.textDarkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, ArchiveProvider archiveProv, AuthProvider authProv) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 52, color: BreadColors.warmAmber),
            const SizedBox(height: 14),
            Text(
              'Unable to load recipes',
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              archiveProv.errorMessage ?? 'Please check your connection or server settings.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                archiveProv.loadArchives(authProv.serverUrl);
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry Connection'),
            ),
          ],
        ),
      ),
    );
  }
}
