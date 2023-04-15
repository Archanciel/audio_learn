import 'package:flutter/material.dart';

import '../services/theme_service.dart';

enum AppTheme { light, dark }

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.light;
  final ThemeService _themeService = ThemeService();

  AppTheme get currentTheme => _currentTheme;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _currentTheme = await _themeService.loadTheme();
    notifyListeners();
  }

  void toggleTheme() async {
    if (_currentTheme == AppTheme.light) {
      _currentTheme = AppTheme.dark;
    } else {
      _currentTheme = AppTheme.light;
    }
    await _themeService.saveTheme(_currentTheme);
    notifyListeners();
  }
}
