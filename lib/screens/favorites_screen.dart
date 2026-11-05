import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/theme/bread_colors.dart';
import '../providers/favorites_provider.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

/// Screen displaying locally saved offline favorite recipes.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final favProv = context.watch<FavoritesProvider>();
    final allFavs = favProv.favorites;

    final filtered = _filter.trim().isEmpty
        ? allFavs
        : allFavs.where((r) {
            final q = _filter.toLowerCase().trim();
            return r.name.toLowerCase().contains(q) ||
                r.teaser.toLowerCase().contains(q) ||
                (r.archiveName ?? '').toLowerCase().contains(q);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recipes'),
        bottom: allFavs.isNotEmpty
            ? PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search saved recipes...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _filter.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _filter = '');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onChanged: (val) {
                      setState(() => _filter = val);
                    },
                  ),
                ),
              )
            : null,
      ),
      body: allFavs.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: BreadColors.crustGold.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.heart,
                          size: 36,
                          color: BreadColors.crustGoldDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No Saved Recipes Yet',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the heart icon on any recipe to save it locally for offline viewing anytime, even without an internet connection.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? BreadColors.textLightMuted : BreadColors.textDarkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : filtered.isEmpty
              ? Center(
                  child: Text(
                    'No saved recipes match "$_filter".',
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final recipe = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: RecipeCard(
                        recipe: recipe,
                        isFavorite: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecipeDetailScreen(
                                recipeId: recipe.id,
                                recipeName: recipe.name,
                                initialCoverUrl: recipe.coverImageUrl,
                              ),
                            ),
                          );
                        },
                        onToggleFavorite: () {
                          favProv.removeFavorite(recipe.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Removed "${recipe.name}" from favorites.'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
