import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PhotoService {
  static final PhotoService _instance = PhotoService._internal();
  factory PhotoService() => _instance;
  PhotoService._internal();

  // Путь к директории с фото, инициализируется при первом вызове _getPhotosDirectory
  static String? _photosDirPath;
  final ImagePicker _picker = ImagePicker();

  /// Получить директорию для сохранения фото профилей
  Future<Directory> _getPhotosDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(path.join(appDir.path, 'profile_photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    // Сохраняем путь для синхронного резолвинга
    _photosDirPath = photosDir.path;
    return photosDir;
  }

  /// Выбрать фото из галереи
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Сжатие для экономии места
        maxWidth: 800, // Максимальная ширина
        maxHeight: 800, // Максимальная высота
      );

      if (image == null) return null;

      return await _saveImage(image);
    } catch (e) {
      debugPrint('Ошибка при выборе фото: $e');
      return null;
    }
  }

  /// Сделать фото камерой
  Future<String?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image == null) return null;

      return await _saveImage(image);
    } catch (e) {
      debugPrint('Ошибка при съемке фото: $e');
      return null;
    }
  }

  /// Сохранить изображение в локальное хранилище
  /// Сохраняет изображение в папку `profile_photos` и возвращает только имя файла (basename).
  Future<String> _saveImage(XFile image) async {
    final photosDir = await _getPhotosDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
    final savedImage = File(path.join(photosDir.path, fileName));

    await image.saveTo(savedImage.path);
    debugPrint('PhotoService: saved image to ${savedImage.path}');
    return fileName; // возвращаем basename, чтобы хранить переносимый идентификатор файла
  }

  /// Удалить фото
  Future<void> deletePhoto(String? photoPath) async {
    if (photoPath == null || photoPath.isEmpty) return;

    try {
      // Попробуем безопасно удалить файл: поддерживаем как абсолютный путь, так и basename

      final candidatePaths = <String>[photoPath];

      // Если это basename или относительный путь, добавим вариант в папке profile_photos
      if (_photosDirPath != null) {
        candidatePaths.add(path.join(_photosDirPath!, photoPath));
        // Если передали абсолютный путь, попробуем использовать только basename
        final base = path.basename(photoPath);
        if (base != photoPath) candidatePaths.add(path.join(_photosDirPath!, base));
      }

      for (final p in candidatePaths) {
        try {
          final file = File(p);
          if (await file.exists()) {
            await file.delete();
            debugPrint('PhotoService: deleted photo at $p');
            return;
          }
        } catch (_) {
          // Игнорируем и пробуем следующий вариант
        }
      }
    } catch (e) {
      debugPrint('PhotoService: ошибка при удалении фото: $e');
    }
  }

  /// Логирует путь к директории с фото и список файлов в ней.
  Future<void> logPhotosDirectoryContents() async {
    try {
      final photosDir = await _getPhotosDirectory();
      debugPrint('PhotoService: photos directory: ${photosDir.path}');
      final files = photosDir.listSync();
      if (files.isEmpty) {
        debugPrint('PhotoService: photos directory is empty');
      } else {
        for (final f in files) {
          try {
            final stat = f.statSync();
            debugPrint('PhotoService: file: ${f.path} (${stat.type}, ${stat.size} bytes)');
          } catch (e) {
            debugPrint('PhotoService: file: ${f.path} (stat error: $e)');
          }
        }
      }
    } catch (e) {
      debugPrint('PhotoService: failed to list photos directory: $e');
    }
  }

  /// Проверить существование фото (асинхронно)
  Future<bool> photoExists(String? photoPath) async {
    if (photoPath == null || photoPath.isEmpty) return false;

    try {
      // Проверяем несколько вариантов: абсолютный путь и файл внутри photosDir

      final candidatePaths = <String>[photoPath];
      if (_photosDirPath != null) {
        candidatePaths.add(path.join(_photosDirPath!, photoPath));
        final base = path.basename(photoPath);
        if (base != photoPath) candidatePaths.add(path.join(_photosDirPath!, base));
      }

      for (final p in candidatePaths) {
        try {
          final file = File(p);
          if (await file.exists()) return true;
        } catch (_) {}
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Проверить существование фото (синхронно)
  bool photoExistsSync(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) return false;

    try {
      // Синхронная проверка: используем сохранённый путь к photosDir, если он инициализирован
      final candidatePaths = <String>[photoPath];
      if (_photosDirPath != null) {
        candidatePaths.add(path.join(_photosDirPath!, photoPath));
        final base = path.basename(photoPath);
        if (base != photoPath) candidatePaths.add(path.join(_photosDirPath!, base));
      }

      for (final p in candidatePaths) {
        try {
          final file = File(p);
          if (file.existsSync()) return true;
        } catch (_) {}
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Синхронно возвращает реальный путь к сохранённому фото, либо null если не найден.
  String? resolvePhotoPathSync(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) return null;

    final candidatePaths = <String>[photoPath];
    if (_photosDirPath != null) {
      candidatePaths.add(path.join(_photosDirPath!, photoPath));
      final base = path.basename(photoPath);
      if (base != photoPath) candidatePaths.add(path.join(_photosDirPath!, base));
    }

    for (final p in candidatePaths) {
      try {
        final file = File(p);
        if (file.existsSync()) return p;
      } catch (_) {}
    }
    return null;
  }

  /// Асинхронно возвращает `File` для указанного `photoPath` (поддерживает basename и абсолютный путь).
  Future<File?> getFileForPhotoPath(String? photoPath) async {
    if (photoPath == null || photoPath.isEmpty) return null;
    // Сначала проверяем абсолютный путь
    try {
      final abs = File(photoPath);
      if (await abs.exists()) return abs;
    } catch (_) {}

    // Иначе собираем путь в profile_photos (попробуем и basename для абсолютных путей)
    try {
      final photosDir = await _getPhotosDirectory();
      final candidate = File(path.join(photosDir.path, photoPath));
      if (await candidate.exists()) return candidate;
      final base = path.basename(photoPath);
      if (base != photoPath) {
        final candidate2 = File(path.join(photosDir.path, base));
        if (await candidate2.exists()) return candidate2;
      }
    } catch (_) {}

    return null;
  }
}

