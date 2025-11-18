import 'package:flutter/material.dart';

/// Единые текстовые стили для всего приложения.
/// Помогают сделать типографику цельной и «дорогой».
class AppTextStyles {
  const AppTextStyles._();

  /// Крупный заголовок экрана / имени.
  static TextStyle heading1(BuildContext context) {
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.2,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Заголовки блоков («Идеи подарков», «Уже подарено» и т.п.).
  static TextStyle heading2(BuildContext context) {
    return TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 1.25,
      letterSpacing: 0.3,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Основной текст (заметки, детали).
  static TextStyle body(BuildContext context) {
    return TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.4,
      letterSpacing: 0.1,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Вторичный текст (подписи, подсказки).
  static TextStyle secondary(BuildContext context) {
    return TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.4,
      letterSpacing: 0.1,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
    );
  }

  /// Текст для маленьких подсказок и пустых состояний.
  static TextStyle caption(BuildContext context) {
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.35,
      letterSpacing: 0.1,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
    );
  }

  /// Текст в кнопках / акцентных элементах.
  static TextStyle button(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      color: Theme.of(context).colorScheme.onPrimary,
    );
  }
}


