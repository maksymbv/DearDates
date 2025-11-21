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
        return 0xFFE91E63; // Розовый
      case AppTheme.blue:
        return 0xFF2196F3; // Яркий синий
    }
  }
  
}

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'app_theme';
  static const String _brightnessKey = 'theme_brightness';
  static final ThemeService _instance = ThemeService._internal();
  
  factory ThemeService() => _instance;
  ThemeService._internal();
  
  AppTheme _currentTheme = AppTheme.pink;
  Brightness _brightness = Brightness.light;
  
  AppTheme get currentTheme => _currentTheme;
  Brightness get brightness => _brightness;
  bool get isDarkMode => _brightness == Brightness.dark;
  
  int get primaryColor => _currentTheme.primaryColor;
  
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null && themeIndex >= 0 && themeIndex < AppTheme.values.length) {
      _currentTheme = AppTheme.values[themeIndex];
    } else {
      // Если сохраненная тема больше не существует, сбрасываем на розовую
      _currentTheme = AppTheme.pink;
      await prefs.setInt(_themeKey, AppTheme.pink.index);
    }
    
    final brightnessIndex = prefs.getInt(_brightnessKey);
    if (brightnessIndex != null) {
      _brightness = brightnessIndex == 0 ? Brightness.light : Brightness.dark;
    }
    
    notifyListeners();
  }
  
  Future<void> setTheme(AppTheme theme) async {
    if (_currentTheme != theme) {
      _currentTheme = theme;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, theme.index);
      notifyListeners();
    }
  }
  
  Future<void> setBrightness(Brightness brightness) async {
    if (_brightness != brightness) {
      _brightness = brightness;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_brightnessKey, brightness == Brightness.light ? 0 : 1);
      notifyListeners();
    }
  }
  
  Future<void> toggleBrightness() async {
    await setBrightness(_brightness == Brightness.light ? Brightness.dark : Brightness.light);
  }
}

