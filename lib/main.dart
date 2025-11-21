import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'models/profile.dart';
import 'dart:io';
import 'models/group.dart';
import 'services/theme_service.dart';
import 'services/notification_service.dart';
import 'adapters/date_time_adapter.dart';
import 'services/photo_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Устанавливаем ориентацию только портретная
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Инициализация Hive
  await Hive.initFlutter();
  
  // Регистрация адаптеров
  Hive.registerAdapter(DateTimeAdapter());
  Hive.registerAdapter(ProfileAdapter());
  Hive.registerAdapter(GiftAdapter());
  Hive.registerAdapter(GroupAdapter());
  
  // Открытие боксов
  await Hive.openBox<Profile>('profiles');
  await Hive.openBox<Group>('groups');

  // Логируем содержимое папки с фото (для отладки пропажи картинок)
  try {
    final photoService = PhotoService();
    await photoService.logPhotosDirectoryContents();
  } catch (e) {
    debugPrint('Failed to list profile photos: $e');
  }

  // Логируем профили и их photoPath + существование файла
  try {
    final profilesBox = Hive.box<Profile>('profiles');
    if (profilesBox.isEmpty) {
      debugPrint('No profiles found in Hive.');
    } else {
      final photoService = PhotoService();
      for (final p in profilesBox.values) {
        final storedPath = p.photoPath;
        final resolved = photoService.resolvePhotoPathSync(storedPath);
        final exists = resolved != null;
        debugPrint('Profile ${p.id}: photoPath="$storedPath" exists=$exists');
      }
    }
  } catch (e) {
    debugPrint('Failed to log profiles/photoPath: $e');
  }
  
  // Инициализация часовых поясов для уведомлений
  tz.initializeTimeZones();
  
  // Загрузка темы
  final themeService = ThemeService();
  await themeService.loadTheme();
  
  // Инициализация уведомлений (с обработкой ошибок)
  try {
    final notificationService = NotificationService();
    await notificationService.initialize();
  } catch (e) {
    // Игнорируем ошибки инициализации уведомлений
    debugPrint('Failed to initialize notifications: $e');
  }
  
  runApp(MyApp(themeService: themeService));
}
