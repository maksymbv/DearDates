import 'package:flutter/material.dart';

/// Константы цветов для приложения
class AppColors {
  // Светлая тема
  static const Color lightBackground = Color(0xFFF8F6F6);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE0E0E0); // Colors.grey[200]!
  static const Color lightText = Color(0xFF1A1A1A);
  static const Color lightSecondaryText = Color(0xFF757575); // Colors.grey[600]
  static const Color lightIcon = Color(0xFF424242); // Colors.grey[800]

  // Темная тема
  static const Color darkBackground = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);
  static const Color darkBorder = Color(0xFF424242); // Colors.grey[800]!
  static const Color darkText = Colors.white;
  static const Color darkSecondaryText = Colors.white70;
  static const Color darkIcon = Colors.white;
}

/// Extension для получения цветов темы
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  final Color background;
  final Color card;
  final Color border;
  final Color text;
  final Color secondaryText;
  final Color icon;

  AppColorScheme({
    required this.background,
    required this.card,
    required this.border,
    required this.text,
    required this.secondaryText,
    required this.icon,
  });

  static AppColorScheme light() => AppColorScheme(
        background: AppColors.lightBackground,
        card: AppColors.lightCard,
        border: AppColors.lightBorder,
        text: AppColors.lightText,
        secondaryText: AppColors.lightSecondaryText,
        icon: AppColors.lightIcon,
      );

  static AppColorScheme dark() => AppColorScheme(
        background: AppColors.darkBackground,
        card: AppColors.darkCard,
        border: AppColors.darkBorder,
        text: AppColors.darkText,
        secondaryText: AppColors.darkSecondaryText,
        icon: AppColors.darkIcon,
      );

  @override
  ThemeExtension<AppColorScheme> copyWith({
    Color? background,
    Color? card,
    Color? border,
    Color? text,
    Color? secondaryText,
    Color? icon,
  }) {
    return AppColorScheme(
      background: background ?? this.background,
      card: card ?? this.card,
      border: border ?? this.border,
      text: text ?? this.text,
      secondaryText: secondaryText ?? this.secondaryText,
      icon: icon ?? this.icon,
    );
  }

  @override
  ThemeExtension<AppColorScheme> lerp(
    ThemeExtension<AppColorScheme>? other,
    double t,
  ) {
    if (other is! AppColorScheme) {
      return this;
    }
    return AppColorScheme(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      icon: Color.lerp(icon, other.icon, t)!,
    );
  }
}

