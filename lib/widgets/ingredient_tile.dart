import 'package:flutter/material.dart';
import '../core/theme/bread_colors.dart';
import '../data/models/ingredient_model.dart';

/// Interactive ingredient list item with scaling and prep checklist checkbox.
class IngredientTile extends StatelessWidget {
  final IngredientModel ingredient;
  final double scaleMultiplier;
  final bool isChecked;
  final VoidCallback onToggle;

  const IngredientTile({
    super.key,
    required this.ingredient,
    required this.scaleMultiplier,
    required this.isChecked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final scaledText = ingredient.displayQuantityScaled(scaleMultiplier);

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isChecked
              ? (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03))
              : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isChecked
                ? theme.colorScheme.outline.withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: isDark ? 0.4 : 0.8),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: isChecked,
                onChanged: (_) => onToggle(),
                activeColor: BreadColors.crustGoldDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Quantity & Unit
            if (scaledText.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: BreadColors.crustGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  scaledText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: BreadColors.crustGoldDark,
                    decoration: isChecked ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            if (scaledText.isNotEmpty) const SizedBox(width: 10),

            // Ingredient Name & Notes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ingredient.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isChecked
                          ? (isDark ? BreadColors.textLightMuted : BreadColors.textDarkMuted)
                          : theme.textTheme.bodyMedium?.color,
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (ingredient.notes.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      ingredient.notes,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: isDark ? BreadColors.textLightMuted : BreadColors.textDarkMuted,
                        decoration: isChecked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Baker's Percentage Tag
            if (ingredient.bakersPercentage != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: (isDark ? BreadColors.toastSurface : BreadColors.crumbWarmGrey),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  '${ingredient.bakersPercentage!.toInt()}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? BreadColors.butterYellow : BreadColors.crustDeep,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
