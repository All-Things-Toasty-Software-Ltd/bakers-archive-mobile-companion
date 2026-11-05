import 'package:flutter/material.dart';

import '../data/models/recipe_detail.dart';

/// Distraction-free, large-text, step-by-step baking mode.
///
/// The full kitchen mode experience is added in a later step.
class KitchenModeScreen extends StatelessWidget {
  final RecipeDetail recipe;

  const KitchenModeScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kitchen Mode')),
      body: const Center(child: Text('Kitchen Mode will appear here.')),
    );
  }
}
