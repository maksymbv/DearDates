import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/profile.dart';
import '../utils/date_utils.dart';
import 'storage_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final StorageService _storageService = StorageService();
  
  // Настройки уведомлений по умолчанию
  static const List<int> defaultReminderDays = [1, 3, 7];
  
  bool _initialized = false;

  // Инициализация уведомлений
  Future<void> initialize() async {
    if (_initialized) return;

    // Инициализация timezone
    tz.initializeTimeZones();

    // Настройки для Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Настройки для iOS и macOS (используют одинаковые Darwin настройки)
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
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
    if (!_initialized) await initialize();

    // Отменяем все существующие уведомления
    await cancelAllNotifications();

    final profiles = await _storageService.loadProfiles();
    final reminderDays = await getReminderDays();

    for (final profile in profiles) {
      await scheduleProfileNotifications(profile, reminderDays);
    }
  }

  // Планирование уведомлений для конкретного профиля
  Future<void> scheduleProfileNotifications(Profile profile, List<int> reminderDays) async {
    if (!_initialized) await initialize();

    final nextBirthday = calculateNextBirthday(profile.birthdate);
    
    // Получаем локальный часовой пояс
    final local = tz.local;
    final nowTz = tz.TZDateTime.now(local);

    // Конвертируем nextBirthday в TZDateTime с временем 10:00 утра
    final birthdayTz = tz.TZDateTime(
      local,
      nextBirthday.year,
      nextBirthday.month,
      nextBirthday.day,
      10, // 10:00 утра
      0,
    );

    // Проверяем, не прошел ли уже день рождения
    if (birthdayTz.isBefore(nowTz) || birthdayTz.isAtSameMomentAs(nowTz)) {
      return;
    }

    // Создаем уведомления для каждого дня напоминания
    for (final daysBefore in reminderDays) {
      final notificationDate = birthdayTz.subtract(Duration(days: daysBefore));
      
      // Планируем только будущие уведомления
      if (notificationDate.isAfter(nowTz)) {
        await _scheduleNotification(
          id: _getNotificationId(profile.id, daysBefore),
          title: 'День рождения скоро! 🎂',
          body: _getNotificationBody(profile.name, daysBefore, nextBirthday),
          scheduledDate: notificationDate,
          profileId: profile.id,
        );
      }
    }

    // Также планируем уведомление в сам день рождения
    if (birthdayTz.isAfter(nowTz)) {
      await _scheduleNotification(
        id: _getNotificationId(profile.id, 0),
        title: 'Сегодня день рождения! 🎉',
        body: 'Сегодня день рождения у ${profile.name}!',
        scheduledDate: birthdayTz,
        profileId: profile.id,
      );
    }
  }

  // Планирование одного уведомления
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required String profileId,
  }) async {

    const androidDetails = AndroidNotificationDetails(
      'birthday_reminders',
      'Напоминания о днях рождения',
      channelDescription: 'Уведомления о приближающихся днях рождения',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // Игнорируем ошибки планирования (например, если дата в прошлом)
      // print('Ошибка планирования уведомления: $e');
    }
  }

  // Получение ID уведомления
  int _getNotificationId(String profileId, int daysBefore) {
    // Используем хеш профиля и дней для уникального ID
    return (profileId.hashCode + daysBefore).abs() % 2147483647;
  }

  // Формирование текста уведомления
  String _getNotificationBody(String name, int daysBefore, DateTime birthday) {
    if (daysBefore == 0) {
      return 'Сегодня день рождения у $name!';
    }
    
    final daysText = _getDaysText(daysBefore);
    final birthdayText = formatDate(birthday);
    return 'Через $daysBefore $daysText день рождения у $name ($birthdayText)';
  }

  // Получение правильной формы слова "день"
  String _getDaysText(int days) {
    if (days % 10 == 1 && days % 100 != 11) {
      return 'день';
    }
    if (days % 10 >= 2 && days % 10 <= 4 && (days % 100 < 10 || days % 100 >= 20)) {
      return 'дня';
    }
    return 'дней';
  }

  // Отмена всех уведомлений
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Отмена уведомлений для конкретного профиля
  Future<void> cancelProfileNotifications(String profileId, List<int> reminderDays) async {
    for (final daysBefore in reminderDays) {
      await _notifications.cancel(_getNotificationId(profileId, daysBefore));
    }
    // Отменяем уведомление в день рождения
    await _notifications.cancel(_getNotificationId(profileId, 0));
  }
}

