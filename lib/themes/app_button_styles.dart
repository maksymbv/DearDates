import 'package:flutter/material.dart';

/// Стили кнопок для приложения
class AppButtonStyles {
  /// Стиль для красной кнопки удаления
  static ButtonStyle deleteButton(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ).copyWith(
      splashFactory: NoSplash.splashFactory,
    );
  }

  /// Стиль для основной кнопки (с цветом темы)
  static ButtonStyle primaryButton(BuildContext context, Color primaryColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ).copyWith(
      splashFactory: NoSplash.splashFactory,
    );
  }

  /// Стиль для текстовой кнопки удаления (без фона)
  static ButtonStyle deleteTextButton(BuildContext context) {
    return TextButton.styleFrom(
      foregroundColor: Colors.red,
      padding: const EdgeInsets.symmetric(vertical: 16),
    ).copyWith(
      splashFactory: NoSplash.splashFactory,
    );
  }

  /// Стиль для модального окна (контейнер)
  static BoxDecoration modalContainer(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    );
  }
}

