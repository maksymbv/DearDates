import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/profile.dart';
import '../localization/app_localizations.dart';
import '../utils/date_utils.dart';
import 'storage_service.dart';
import 'notification_text_builder.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final StorageService _storage = StorageService();
  
  // Настройки уведомлений по умолчанию
  static const List<int> defaultReminderDays = [1, 3, 7, 14, 30];
  
  bool _initialized = false;

  // Инициализация уведомлений
  Future<void> initialize() async {
    if (_initialized) return;

    // Инициализация timezone
    tz.initializeTimeZones();

    // Настройки для Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Настройки для iOS
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Запрашиваем разрешения для Android 13+
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();

    _initialized = true;
  }

  // Обработка нажатия на уведомление
  void _onNotificationTapped(NotificationResponse response) {
    // Можно добавить навигацию к профилю
  }

  // Получение настроек уведомлений из хранилища
  Future<List<int>> getReminderDays() async {
    final prefs = await SharedPreferences.getInstance();
    final daysString = prefs.getString('reminder_days');
    if (daysString != null) {
      return daysString.split(',').map((d) => int.parse(d)).toList();
    }
    return defaultReminderDays;
  }

  // Сохранение настроек уведомлений
  Future<void> setReminderDays(List<int> days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reminder_days', days.join(','));
    // Перепланируем уведомления с новыми настройками
    await scheduleAllNotifications();
  }

  // Планирование уведомлений для всех профилей
  Future<void> scheduleAllNotifications() async {
    await initialize();
    await cancelAllNotifications();
    final profiles = await _storage.loadProfiles();
    final reminderDays = await getReminderDays();
    for (final profile in profiles) {
      await scheduleProfile(profile, reminderDays);
    }
  }

  // Планирование уведомлений для конкретного профиля
  Future<void> scheduleProfile(Profile profile, List<int> reminderDays) async {
    await initialize();
    
    final loc = await _createTextBuilder();
    final nextBirthday = calculateNextBirthday(profile.birthdate);
    final birthday = tz.TZDateTime(
      tz.local,
      nextBirthday.year,
      nextBirthday.month,
      nextBirthday.day,
      10, // 10:00 утра
      0,
    );
    
    if (!birthday.isAfter(tz.TZDateTime.now(tz.local))) return;

    // 1) Напоминания заранее
    final birthdayDate = DateTime(birthday.year, birthday.month, birthday.day);
    for (final days in reminderDays) {
      final date = birthday.subtract(Duration(days: days));
      if (date.isAfter(tz.TZDateTime.now(tz.local))) {
        await _schedule(
          id: _id(profile, days),
          title: loc.titleForReminder(),
          body: loc.bodyForReminder(profile.name, days, birthdayDate),
          date: date,
        );
      }
    }

    // 2) День рождения
    await _schedule(
      id: _id(profile, 0),
      title: loc.titleForBirthday(),
      body: loc.bodyForBirthday(profile.name),
      date: birthday,
    );
  }

  // Создание NotificationTextBuilder с английской локалью
  Future<NotificationTextBuilder> _createTextBuilder() async {
    final localizations = AppLocalizations(Locale('en', 'US'));
    return NotificationTextBuilder(localizations);
  }

  // Планирование одного уведомления
  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime date,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'birthday_channel',
        'Birthday reminders',
        channelDescription: 'Notifications about upcoming birthdays',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        date,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      // Игнорируем ошибки планирования (например, если дата в прошлом)
    }
  }

  // Генерация ID уведомления
  int _id(Profile profile, int days) => Object.hash(profile.id, days);
  int _idFromString(String profileId, int days) => Object.hash(profileId, days);

  // Отмена всех уведомлений
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Отмена уведомлений для конкретного профиля
  Future<void> cancelProfileNotifications(String profileId, List<int> reminderDays) async {
    for (final daysBefore in reminderDays) {
      await _notifications.cancel(_idFromString(profileId, daysBefore));
    }
    // Отменяем уведомление в день рождения
    await _notifications.cancel(_idFromString(profileId, 0));
  }
}
