import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/bread_theme.dart';

void main() {
  runApp(const BakersArchiveApp());
}

/// The new Flutter shell for The Baker's Archive Mobile Companion.
///
/// The Kotlin Multiplatform app remains in place while the new design is
/// brought across feature by feature.
class BakersArchiveApp extends StatelessWidget {
  const BakersArchiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: BreadTheme.lightTheme,
      darkTheme: BreadTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const Scaffold(
        body: Center(
          child: Text(AppConstants.appName),
        ),
      ),
    );
  }
}
