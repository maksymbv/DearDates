import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Расширение для BuildContext с общими методами работы с темой
/// Устраняет дублирование кода во всех экранах
extension ThemeHelper on BuildContext {
  /// Получить AppColorScheme из темы
  AppColorScheme get _appColors => Theme.of(this).extension<AppColorScheme>() ?? 
    (isDarkMode ? AppColorScheme.dark() : AppColorScheme.light());
  
  /// Основной цвет текста
  Color get textColor => _appColors.text;
  
  /// Вторичный цвет текста
  Color get secondaryTextColor => _appColors.secondaryText;
  
  /// Цвет иконок
  Color get iconColor => _appColors.icon;
  
  /// Проверка темной темы
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  /// Тени для карточек (менее заметные в темной теме)
  List<BoxShadow> get cardShadows {
    if (isDarkMode) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];
    }
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 20,
        offset: const Offset(0, 4),
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.02),
        blurRadius: 6,
        offset: const Offset(0, 2),
        spreadRadius: 0,
      ),
    ];
  }
  
  /// Получить более темный оттенок цвета для градиента
  Color getDarkerShade(int color) {
    final baseColor = Color(color);
    return Color.fromRGBO(
      (baseColor.red * 0.85).round().clamp(0, 255),
      (baseColor.green * 0.85).round().clamp(0, 255),
      (baseColor.blue * 0.85).round().clamp(0, 255),
      1.0,
    );
  }
}

