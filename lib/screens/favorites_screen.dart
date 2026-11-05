import 'package:flutter/material.dart';

/// The saved / offline favourites tab.
///
/// The full offline library is added in a later step of the migration.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Recipes')),
      body: const Center(child: Text('Saved recipes will appear here.')),
    );
  }
}
