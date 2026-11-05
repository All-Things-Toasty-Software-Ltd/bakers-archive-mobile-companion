import 'package:flutter/material.dart';

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
      title: "The Baker's Archive",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFD97706),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text("The Baker's Archive"),
        ),
      ),
    );
  }
}
