import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/theme/bread_colors.dart';
import '../data/models/recipe_summary.dart';

/// Card widget presenting a recipe in list feeds and explore grids.
class RecipeCard extends StatelessWidget {
  final RecipeSummary recipe;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dateFormatted = recipe.publishedDate != null
        ? DateFormat('d MMM yyyy').format(recipe.publishedDate!)
        : null;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.4 : 0.8),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image with Scrim Gradient & Badges
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (recipe.coverImageUrl != null && recipe.coverImageUrl!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: recipe.coverImageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: isDark ? BreadColors.toastSurface : BreadColors.crumbWarmGrey,
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.breadSlice,
                            color: BreadColors.crustGold.withValues(alpha: 0.3),
                            size: 32,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => _buildPlaceholder(isDark),
                    )
                  else
                    _buildPlaceholder(isDark),

                  // Top Badges
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (recipe.archiveName != null && recipe.archiveName!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              recipe.archiveName!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),

                        // Favorite Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onToggleFavorite,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.redAccent : Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Recipe Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (recipe.teaser.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      recipe.teaser,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Footer info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (dateFormatted != null)
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: isDark ? BreadColors.textLightMuted : BreadColors.textDarkMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dateFormatted,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? BreadColors.textLightMuted : BreadColors.textDarkMuted,
                              ),
                            ),
                          ],
                        )
                      else
                        const SizedBox.shrink(),

                      Row(
                        children: [
                          Text(
                            'View Recipe',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      color: isDark ? BreadColors.toastSurface : BreadColors.crumbWarmGrey,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.breadSlice,
              color: BreadColors.crustGold.withValues(alpha: 0.4),
              size: 36,
            ),
            const SizedBox(height: 6),
            Text(
              "Baker's Archive",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: BreadColors.crustGold.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
