import 'package:flutter/material.dart';

/// The application settings tab.
///
/// Server configuration, Odoo authentication and theme controls are added as
/// the migration continues.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Settings')),
      body: const Center(child: Text('Settings will appear here.')),
    );
  }
}
