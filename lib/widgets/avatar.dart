import 'dart:io';
import 'package:flutter/material.dart';
import '../services/photo_service.dart';

/// Универсальный виджет для отображения аватара профиля
/// Обрабатывает проверку существования фото и placeholder с инициалом
class AvatarWidget extends StatelessWidget {
  final String? photoPath;
  final int avatarColor;
  final String name;
  final double size;
  final double? fontSize;

  const AvatarWidget({
    super.key,
    required this.photoPath,
    required this.avatarColor,
    required this.name,
    this.size = 64,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final photoService = PhotoService();
    final resolvedPath = photoService.resolvePhotoPathSync(photoPath);
    final hasPhoto = resolvedPath != null;
    final displayFontSize = fontSize ?? (size * 0.4);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color(avatarColor),
        shape: BoxShape.circle,
      ),
      child: hasPhoto
          ? ClipOval(
              child: SizedBox(
                width: size,
                height: size,
                child: Image.file(
                  File(resolvedPath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildInitial(context, displayFontSize);
                  },
                ),
              ),
            )
          : _buildInitial(context, displayFontSize),
    );
  }

  Widget _buildInitial(BuildContext context, double fontSize) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '';
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

