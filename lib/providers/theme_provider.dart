import 'package:flutter/material.dart';
import '../data/services/storage_service.dart';

/// Provider for managing artisan bread theme appearance.
class ThemeProvider extends ChangeNotifier {
  final StorageService _storageService;

  ThemeProvider(this._storageService) {
    _mode = _storageService.getThemeMode();
  }

  late String _mode;

  String get currentMode => _mode;

  ThemeMode get themeMode {
    switch (_mode) {
      case 'dark_toast':
        return ThemeMode.dark;
      case 'warm_crust':
        return ThemeMode.light;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setMode(String newMode) async {
    if (_mode == newMode) return;
    _mode = newMode;
    await _storageService.setThemeMode(newMode);
    notifyListeners();
  }
}
