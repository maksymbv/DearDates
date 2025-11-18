import 'package:flutter/material.dart';

/// Получение более темного оттенка цвета для градиента
Color getDarkerShade(int color) {
  final baseColor = Color(color);
  return Color.fromRGBO(
    (baseColor.red * 0.85).round().clamp(0, 255),
    (baseColor.green * 0.85).round().clamp(0, 255),
    (baseColor.blue * 0.85).round().clamp(0, 255),
    1.0,
  );
}

