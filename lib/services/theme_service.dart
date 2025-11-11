import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme {
  pink,
  blue,
}

extension AppThemeExtension on AppTheme {
  String get displayName {
    switch (this) {
      case AppTheme.pink:
        return 'Розовая';
      case AppTheme.blue:
        return 'Синяя';
    }
  }
  
  // Основной цвет темы
  int get primaryColor {
    switch (this) {
      case AppTheme.pink:
        return 0xFFD68A9E;
      case AppTheme.blue:
        return 0xFF7FA8D6;
    }
  }
  
  // Более темный оттенок
  int get primaryDarkColor {
    switch (this) {
      case AppTheme.pink:
        return 0xFFC97A8F;
      case AppTheme.blue:
        return 0xFF6B9AC8;
    }
  }
}

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'app_theme';
  static final ThemeService _instance = ThemeService._internal();
  
  factory ThemeService() => _instance;
  ThemeService._internal();
  
  AppTheme _currentTheme = AppTheme.pink;
  
  AppTheme get currentTheme => _currentTheme;
  
  int get primaryColor => _currentTheme.primaryColor;
  int get primaryDarkColor => _currentTheme.primaryDarkColor;
  
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null && themeIndex >= 0 && themeIndex < AppTheme.values.length) {
      _currentTheme = AppTheme.values[themeIndex];
      notifyListeners();
    }
  }
  
  Future<void> setTheme(AppTheme theme) async {
    if (_currentTheme != theme) {
      _currentTheme = theme;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, theme.index);
      notifyListeners();
    }
  }
}

