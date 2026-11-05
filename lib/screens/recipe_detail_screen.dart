import 'package:flutter/material.dart';

/// A single recipe.
///
/// The full interactive detail view (batch scaling, ingredient checklist,
/// timers and kitchen mode) is added in a later step.
class RecipeDetailScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipeName)),
      body: const Center(child: Text('Recipe details will appear here.')),
    );
  }
}
