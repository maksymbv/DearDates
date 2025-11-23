import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/photo_service.dart';

/// Универсальный виджет для отображения аватара профиля
/// Асинхронно загружает файл изображения и использует уменьшенное декодирование
class AvatarWidget extends StatefulWidget {
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
  State<AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget> {
  Future<File?>? _photoFileFuture;

  @override
  void initState() {
    super.initState();
    _loadPhoto();
  }

  @override
  void didUpdateWidget(covariant AvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photoPath != widget.photoPath) {
      _loadPhoto();
    }
  }

  void _loadPhoto() {
    final service = PhotoService();
    _photoFileFuture = () async {
      // Try thumbnail first, then full image
      final thumb = await service.getThumbnailFileForPhotoPath(widget.photoPath);
      if (thumb != null) return thumb;
      return await service.getFileForPhotoPath(widget.photoPath);
    }();
    // Trigger rebuild
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final displayFontSize = widget.fontSize ?? (widget.size * 0.4);

    return Container(
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color(widget.avatarColor),
        shape: BoxShape.circle,
      ),
      child: FutureBuilder<File?>(
        future: _photoFileFuture,
        builder: (context, snapshot) {
          final file = snapshot.data;
          if (file != null) {
            // Use Image.file with explicit width/height and high filter quality
            // so Flutter can decode an appropriately sized image and scale nicely.
            return ClipOval(
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: Image.file(
                  file,
                  width: widget.size,
                  height: widget.size,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildInitial(context, displayFontSize);
                  },
                ),
              ),
            );
          }

          return _buildInitial(context, displayFontSize);
        },
      ),
    );
  }

  Widget _buildInitial(BuildContext context, double fontSize) {
    final initial = widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '';
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

