import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/theme/bread_colors.dart';
import '../core/utils/bakers_math.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_detail_provider.dart';
import '../providers/favorites_provider.dart';
import '../data/services/storage_service.dart';
import '../widgets/bread_loader.dart';
import '../widgets/ingredient_tile.dart';
import '../widgets/step_timer_widget.dart';
import 'kitchen_mode_screen.dart';
import '../data/models/recipe_detail.dart';

/// Comprehensive recipe detail screen with scaling, checklist, and baking timers.
class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;
  final String recipeName;
  final String? initialCoverUrl;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
    required this.recipeName,
    this.initialCoverUrl,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecipeData();
    });
  }

  void _loadRecipeData() {
    final serverUrl = context.read<AuthProvider>().serverUrl;
    final storage = context.read<StorageService>();
    context.read<RecipeDetailProvider>().loadRecipe(
          widget.recipeId,
          serverUrl,
          storageService: storage,
        );
  }

  void _shareRecipe(String recipeName, String? webUrl, String? teaser) {
    final shareText = StringBuffer(recipeName);
    if (teaser != null && teaser.isNotEmpty) {
      shareText.write('\n\n$teaser');
    }
    if (webUrl != null && webUrl.isNotEmpty) {
      shareText.write('\n\nView recipe: $webUrl');
    }
    Share.share(shareText.toString(), subject: recipeName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final detailProv = context.watch<RecipeDetailProvider>();
    final favProv = context.watch<FavoritesProvider>();
    final recipe = detailProv.recipe;

    final isFav = favProv.isFavorite(widget.recipeId);

    return Scaffold(
      body: detailProv.isLoading && recipe == null
          ? Scaffold(
              appBar: AppBar(title: Text(widget.recipeName)),
              body: const BreadLoader(message: 'Baking recipe details...'),
            )
          : detailProv.errorMessage != null && recipe == null
              ? Scaffold(
                  appBar: AppBar(title: Text(widget.recipeName)),
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wifi_off_rounded, size: 48, color: theme.colorScheme.error),
                          const SizedBox(height: 16),
                          Text(
                            detailProv.errorMessage!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadRecipeData,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    // Hero App Bar with Cover Image
                    SliverAppBar(
                      expandedHeight: 280,
                      pinned: true,
                      backgroundColor: theme.scaffoldBackgroundColor,
                      leading: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: 0.55),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      actions: [
                        if (recipe != null) ...[
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CircleAvatar(
                              backgroundColor: Colors.black.withValues(alpha: 0.55),
                              child: IconButton(
                                icon: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  color: isFav ? Colors.redAccent : Colors.white,
                                  size: 20,
                                ),
                                onPressed: () {
                                  favProv.toggleFavorite(recipe);
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: CircleAvatar(
                              backgroundColor: Colors.black.withValues(alpha: 0.55),
                              child: IconButton(
                                icon: const Icon(Icons.share, color: Colors.white, size: 18),
                                onPressed: () {
                                  _shareRecipe(recipe.name, recipe.webUrl, recipe.teaser);
                                },
                              ),
                            ),
                          ),
                        ],
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (recipe?.mainImageUrl != null || widget.initialCoverUrl != null)
                              CachedNetworkImage(
                                imageUrl: recipe?.mainImageUrl ?? widget.initialCoverUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => _buildImagePlaceholder(isDark),
                              )
                            else
                              _buildImagePlaceholder(isDark),

                            // Scrim gradient
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.8),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),

                            // Archive Tag
                            if (recipe?.archiveName != null)
                              Positioned(
                                bottom: 20,
                                left: 20,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: BreadColors.crustGoldDark,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    recipe!.archiveName!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Recipe Content
                    if (recipe != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Offline Indicator Banner if applicable
                              if (detailProv.isOfflineFallback)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: BreadColors.warmAmber.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: BreadColors.warmAmber.withValues(alpha: 0.4)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.offline_bolt_rounded, color: BreadColors.warmAmber, size: 20),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Viewing saved offline copy from your Favorites.',
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Recipe Title & Subtitle
                              Text(
                                recipe.name,
                                style: theme.textTheme.displayMedium?.copyWith(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  height: 1.25,
                                ),
                              ),
                              if (recipe.subtitle != null && recipe.subtitle!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  recipe.subtitle!,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: isDark ? BreadColors.textLightSecondary : BreadColors.textDarkSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),

                              // Author & Attribution Row
                              _buildAuthorRow(recipe, isDark, theme),
                              const SizedBox(height: 20),

                              // Quick Stats Cards
                              _buildQuickStats(recipe, theme, isDark),
                              const SizedBox(height: 24),

                              // Servings & Batch Scaler
                              _buildBatchScaler(detailProv, theme, isDark),
                              const SizedBox(height: 28),

                              // Ingredients Section
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Ingredients',
                                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
                                  ),
                                  TextButton(
                                    onPressed: () => detailProv.resetChecklist(),
                                    child: const Text('Reset Checks'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              if (recipe.ingredients.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Text('No structured ingredients listed.'),
                                )
                              else
                                ...recipe.ingredients.map(
                                  (ing) => IngredientTile(
                                    ingredient: ing,
                                    scaleMultiplier: detailProv.scaleMultiplier,
                                    isChecked: detailProv.checkedIngredientIds.contains(ing.id),
                                    onToggle: () => detailProv.toggleIngredientChecked(ing.id),
                                  ),
                                ),

                              const SizedBox(height: 32),

                              // Instructions Section
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Recipe Instructions',
                                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
                                  ),
                                  if (recipe.instructions.isNotEmpty)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => KitchenModeScreen(recipe: recipe),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.soup_kitchen_rounded, size: 18),
                                      label: const Text('Kitchen Mode'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              if (recipe.instructions.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Text('No instructions listed for this recipe.'),
                                )
                              else
                                ..._buildCategorizedInstructions(recipe, detailProv, theme, isDark),

                              const SizedBox(height: 32),

                              // Description & Baker's Notes
                              if (recipe.description.isNotEmpty) ...[
                                Text(
                                  'Description',
                                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark ? BreadColors.toastSurface : BreadColors.crumbWarmGrey,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.4)),
                                  ),
                                  child: Text(
                                    recipe.description,
                                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],

                              if (recipe.notes.isNotEmpty) ...[
                                Text(
                                  "Baker's Notes",
                                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark ? BreadColors.toastSurface : BreadColors.crumbWarmGrey,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.4)),
                                  ),
                                  child: Text(
                                    recipe.notes,
                                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],

                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildAuthorRow(RecipeDetail recipe, bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? BreadColors.toastSurface : BreadColors.crumbWarmGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: BreadColors.crustGold.withValues(alpha: 0.2),
            backgroundImage: (recipe.authorAvatarUrl != null)
                ? CachedNetworkImageProvider(recipe.authorAvatarUrl!)
                : null,
            child: recipe.authorAvatarUrl == null
                ? FaIcon(FontAwesomeIcons.user, size: 16, color: BreadColors.crustGoldDark)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.originalAuthorName ?? recipe.authorName ?? 'Austin ATTS Baker',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                if (recipe.sourceName != null && recipe.sourceName!.isNotEmpty)
                  Text(
                    'Source: ${recipe.sourceName}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? BreadColors.textLightMuted : BreadColors.textDarkMuted,
                    ),
                  ),
              ],
            ),
          ),
          if (recipe.countryName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
              ),
              child: Text(
                recipe.countryName!,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(RecipeDetail recipe, ThemeData theme, bool isDark) {
    return Row(
      children: [
        _buildStatCard(
          icon: const FaIcon(FontAwesomeIcons.wheatAwn, size: 16, color: BreadColors.crustGoldDark),
          label: 'Ingredients',
          value: '${recipe.ingredients.length}',
          theme: theme,
          isDark: isDark,
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          icon: const Icon(Icons.format_list_numbered_rounded, size: 16, color: BreadColors.crustGoldDark),
          label: 'Steps',
          value: '${recipe.instructions.length}',
          theme: theme,
          isDark: isDark,
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          icon: const Icon(Icons.remove_red_eye_outlined, size: 16, color: BreadColors.crustGoldDark),
          label: 'Views',
          value: '${recipe.visits}',
          theme: theme,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required Widget icon,
    required String label,
    required String value,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.7),
          ),
        ),
        child: Column(
          children: [
            icon,
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? BreadColors.textLightMuted : BreadColors.textDarkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchScaler(RecipeDetailProvider detailProv, ThemeData theme, bool isDark) {
    final multipliers = [0.5, 1.0, 1.5, 2.0, 3.0];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? BreadColors.toastSurface : BreadColors.crumbWarmGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.scale_rounded, size: 18, color: BreadColors.crustGoldDark),
                  SizedBox(width: 8),
                  Text(
                    'Scale Batch Size',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              Text(
                '${detailProv.scaleMultiplier}x',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: BreadColors.crustGoldDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: multipliers.map((m) {
              final isSelected = (detailProv.scaleMultiplier - m).abs() < 0.01;
              return ChoiceChip(
                label: Text('${m == m.roundToDouble() ? m.toInt() : m}x'),
                selected: isSelected,
                onSelected: (_) => detailProv.setScaleMultiplier(m),
                showCheckmark: false,
                selectedColor: BreadColors.crustGoldDark,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategorizedInstructions(
    RecipeDetail recipe,
    RecipeDetailProvider detailProv,
    ThemeData theme,
    bool isDark,
  ) {
    final categorized = recipe.categorizedInstructions;
    final List<Widget> widgets = [];

    int stepCounter = 1;

    for (final entry in categorized.entries) {
      final categoryName = entry.key;
      final stepList = entry.value;

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 8),
          child: Text(
            categoryName,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: BreadColors.crustGoldDark,
            ),
          ),
        ),
      );

      for (final step in stepList) {
        final currentIdx = stepCounter++;
        final isCompleted = detailProv.completedStepIds.contains(step.id);
        final isTimerActive = detailProv.activeTimerStepId == step.id;

        widgets.add(
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isCompleted
                  ? (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03))
                  : theme.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isCompleted
                    ? theme.colorScheme.outline.withValues(alpha: 0.3)
                    : theme.colorScheme.outline.withValues(alpha: isDark ? 0.4 : 0.8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step Number Circle
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: isCompleted
                          ? BreadColors.yeastGreen
                          : BreadColors.crustGold.withValues(alpha: 0.2),
                      child: Text(
                        isCompleted ? '✓' : '$currentIdx',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? Colors.white : BreadColors.crustGoldDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Instruction Step Text
                    Expanded(
                      child: Text(
                        step.text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          height: 1.45,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted
                              ? (isDark ? BreadColors.textLightMuted : BreadColors.textDarkMuted)
                              : theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ],
                ),

                // Timer Action Button if step has time
                if (step.timeMinutes > 0) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (isTimerActive)
                        StepTimerWidget(
                          secondsRemaining: detailProv.timerSecondsRemaining,
                          isRunning: detailProv.isTimerRunning,
                          onPauseResume: () => detailProv.pauseResumeTimer(),
                          onReset: () => detailProv.resetTimer(),
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: () {
                            detailProv.startStepTimer(step.id, step.timeMinutes);
                          },
                          icon: const Icon(Icons.timer_outlined, size: 16),
                          label: Text('Timer (${BakersMath.formatDurationMinutes(step.timeMinutes)})'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),

                      IconButton(
                        tooltip: isCompleted ? 'Mark incomplete' : 'Mark complete',
                        icon: Icon(
                          isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                          color: isCompleted ? BreadColors.yeastGreen : BreadColors.crustGoldDark,
                        ),
                        onPressed: () => detailProv.toggleStepCompleted(step.id),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: isCompleted ? 'Mark incomplete' : 'Mark complete',
                      icon: Icon(
                        isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                        color: isCompleted ? BreadColors.yeastGreen : BreadColors.crustGoldDark,
                      ),
                      onPressed: () => detailProv.toggleStepCompleted(step.id),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }
    }

    return widgets;
  }

  Widget _buildImagePlaceholder(bool isDark) {
    return Container(
      color: isDark ? BreadColors.toastSurface : BreadColors.crumbWarmGrey,
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.breadSlice,
          size: 64,
          color: BreadColors.crustGold.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}
