import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/bread_theme.dart';
import 'data/services/storage_service.dart';
import 'providers/archive_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/recipe_detail_provider.dart';
import 'providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = await StorageService.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(storageService),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(storageService: storageService),
        ),
        ChangeNotifierProvider<ArchiveProvider>(
          create: (_) => ArchiveProvider(),
        ),
        ChangeNotifierProvider<RecipeDetailProvider>(
          create: (_) => RecipeDetailProvider(),
        ),
        ChangeNotifierProvider<FavoritesProvider>(
          create: (_) => FavoritesProvider(storageService),
        ),
      ],
      child: const BakersArchiveApp(),
    ),
  );
}

class BakersArchiveApp extends StatelessWidget {
  const BakersArchiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: BreadTheme.lightTheme,
      darkTheme: BreadTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const Scaffold(
        body: Center(
          child: Text(AppConstants.appName),
        ),
      ),
    );
  }
}
