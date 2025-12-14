import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/profile.dart';
import '../l10n/app_localizations.dart';
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
    
    // Автоматическое определение часового пояса устройства
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      if (kDebugMode) {
        debugPrint('NotificationService: Timezone set to $timeZoneName');
      }
    } catch (e) {
      // Fallback на UTC если не удалось определить
      if (kDebugMode) {
        debugPrint('NotificationService: Failed to get local timezone, using UTC: $e');
      }
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

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

    try {
      final initResult = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      // Инициализация может вернуть bool? на некоторых платформах, игнорируем результат
      if (kDebugMode && (initResult == null || initResult == false)) {
        debugPrint('Notification initialization returned false or null');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing notifications: $e');
      }
      // Продолжаем работу даже если инициализация не удалась
    }

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

  // Получение состояния включения уведомлений
  Future<bool> areNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // По умолчанию уведомления включены
      final value = prefs.getBool('notifications_enabled');
      return value ?? true;
    } catch (e) {
      // В случае ошибки считаем, что уведомления включены
      if (kDebugMode) {
        debugPrint('Error getting notifications enabled state: $e');
      }
      return true;
    }
  }

  // Установка состояния включения уведомлений
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    if (enabled) {
      // Если включили, перепланируем все уведомления
      await scheduleAllNotifications();
    } else {
      // Если выключили, отменяем все уведомления
      await cancelAllNotifications();
    }
  }

  // Получение глобальных настроек уведомлений из хранилища
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
    // Перепланируем уведомления для всех профилей с включенными уведомлениями
    await scheduleAllNotifications();
  }

  // Планирование уведомлений для всех профилей
  Future<void> scheduleAllNotifications() async {
    await initialize();
    // Проверяем, включены ли глобальные уведомления
    final enabled = await areNotificationsEnabled();
    if (!enabled) {
      await cancelAllNotifications();
      return;
    }
    await cancelAllNotifications();
    final profiles = await _storage.loadProfiles();
    final reminderDays = await getReminderDays();
    for (final profile in profiles) {
      // Планируем только если у профиля включены уведомления
      if (profile.notificationsEnabled) {
        await scheduleProfile(profile, reminderDays);
      }
    }
  }

  // Планирование уведомлений для конкретного профиля
  // Если reminderDays не указан, использует глобальные настройки
  Future<void> scheduleProfile(Profile profile, [List<int>? reminderDays]) async {
    await initialize();
    // Проверяем, включены ли глобальные уведомления
    final globalEnabled = await areNotificationsEnabled();
    if (!globalEnabled) {
      return;
    }
    
    // Проверяем, включены ли уведомления для профиля
    if (!profile.notificationsEnabled) {
      return;
    }
    
    // Если дни не указаны, используем глобальные настройки
    final days = reminderDays ?? await getReminderDays();
    
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
    
    // 1) Напоминания заранее
    final birthdayDate = DateTime(birthday.year, birthday.month, birthday.day);
    for (final day in days) {
      final date = birthday.subtract(Duration(days: day));
      if (date.isAfter(tz.TZDateTime.now(tz.local))) {
        await _schedule(
          id: _id(profile, day),
          title: loc.titleForReminder(),
          body: loc.bodyForReminder(profile.name, day, birthdayDate),
          date: date,
        );
      } else {
        if (kDebugMode) {
          debugPrint('NotificationService: skipping scheduling reminder for profile ${profile.id} day=$day date=$date (in past)');
        }
      }
    }

    // 2) День рождения (schedule only if in the future)
    if (birthday.isAfter(tz.TZDateTime.now(tz.local))) {
      await _schedule(
        id: _id(profile, 0),
        title: loc.titleForBirthday(),
        body: loc.bodyForBirthday(profile.name),
        date: birthday,
      );
    } else {
      if (kDebugMode) {
        debugPrint('NotificationService: skipping birthday notification for profile ${profile.id} date=$birthday (in past)');
      }
    }
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
      if (kDebugMode) {
        debugPrint('NotificationService: scheduling id=$id date=$date title="$title"');
      }
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        date,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      if (kDebugMode) {
        debugPrint('NotificationService: scheduled id=$id date=$date');
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('NotificationService: failed to schedule id=$id date=$date error=$e\n$st');
      }
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
