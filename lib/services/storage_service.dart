import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/profile.dart';
import 'notification_service.dart';
import 'photo_service.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  
  factory StorageService() => _instance;
  StorageService._internal();
  
  Box<Profile> get _profilesBox => Hive.box<Profile>('profiles');

  // Генерация случайного пастельного цвета
  static int generatePastelColor() {
    final random = Random();
    final pastelColors = [
      0xFFD68A9E, // Розовый
      0xFFFFB3BA, // Светло-розовый
      0xFFFFDFBA, // Персиковый
      0xFFFFF2BA, // Пастельно-желтый
      0xFFBAFFC9, // Пастельно-зеленый
      0xFFBAE1FF, // Пастельно-голубой
      0xFFC9BAFF, // Пастельно-фиолетовый
      0xFFFFBAE1, // Пастельно-малиновый
      0xFFBAFFE1, // Пастельно-бирюзовый
      0xFFFFE1BA, // Пастельно-оранжевый
      0xFFE1BAFF, // Пастельно-лавандовый
      0xFFBAE1E1, // Пастельно-циан
    ];
    return pastelColors[random.nextInt(pastelColors.length)];
  }

  Future<List<Profile>> loadProfiles() async {
    final profiles = _profilesBox.values.toList();
    
    // Если у профиля нет avatarColor, генерируем случайный
    final needsSave = profiles.any((profile) => profile.avatarColor == 0);
    
    if (needsSave) {
      for (var profile in profiles) {
        if (profile.avatarColor == 0) {
          final updatedProfile = profile.copyWith(avatarColor: generatePastelColor());
          await _profilesBox.put(profile.id, updatedProfile);
        }
      }
      // Перезагружаем после обновления
      return _profilesBox.values.toList();
    }

    return profiles;
  }

  Future<void> saveProfiles(List<Profile> profiles) async {
    // Очищаем бокс и сохраняем все профили
    await _profilesBox.clear();
    final Map<String, Profile> profilesMap = {
      for (var profile in profiles) profile.id: profile
    };
    await _profilesBox.putAll(profilesMap);
  }

  Future<void> addProfile(Profile profile) async {
    await _profilesBox.put(profile.id, profile);
    
    // Планируем уведомления для нового профиля
    try {
      final notificationService = NotificationService();
      final reminderDays = await notificationService.getReminderDays();
      await notificationService.scheduleProfile(profile, reminderDays);
    } catch (e) {
      // Игнорируем ошибки уведомлений, чтобы не блокировать сохранение профиля
      debugPrint('Ошибка при планировании уведомлений: $e');
    }
  }

  Future<void> updateProfile(Profile profile) async {
    final oldProfile = _profilesBox.get(profile.id);
    
    if (oldProfile != null) {
      // Удаляем старое фото, если оно было изменено или удалено
      if (oldProfile.photoPath != null && oldProfile.photoPath != profile.photoPath) {
        final photoService = PhotoService();
        await photoService.deletePhoto(oldProfile.photoPath);
      }
      
      await _profilesBox.put(profile.id, profile);
      
      // Обновляем уведомления для профиля
      try {
        final notificationService = NotificationService();
        final reminderDays = await notificationService.getReminderDays();
        
        // Отменяем старые уведомления
        await notificationService.cancelProfileNotifications(oldProfile.id, reminderDays);
        
        // Планируем новые уведомления
        await notificationService.scheduleProfile(profile, reminderDays);
      } catch (e) {
        // Игнорируем ошибки уведомлений, чтобы не блокировать сохранение профиля
        debugPrint('Ошибка при обновлении уведомлений: $e');
      }
    }
  }

  Future<void> deleteProfile(String profileId) async {
    final profileToDelete = _profilesBox.get(profileId);
    
    if (profileToDelete == null) {
      throw Exception('Profile not found');
    }
    
    // Удаляем фото профиля, если оно есть
    if (profileToDelete.photoPath != null) {
      final photoService = PhotoService();
      await photoService.deletePhoto(profileToDelete.photoPath);
    }
    
    await _profilesBox.delete(profileId);
    
    // Отменяем уведомления для удаленного профиля
    final notificationService = NotificationService();
    final reminderDays = await notificationService.getReminderDays();
    await notificationService.cancelProfileNotifications(profileId, reminderDays);
  }

  Future<void> addGift(String profileId, Gift gift) async {
    final profile = _profilesBox.get(profileId);
    
    if (profile != null) {
      final updatedGifts = List<Gift>.from(profile.gifts)..add(gift);
      final updatedProfile = profile.copyWith(gifts: updatedGifts);
      await _profilesBox.put(profileId, updatedProfile);
    }
  }

  Future<void> updateGift(String profileId, Gift gift) async {
    final profile = _profilesBox.get(profileId);
    
    if (profile != null) {
      final updatedGifts = profile.gifts.map((g) {
        return g.id == gift.id ? gift : g;
      }).toList();
      final updatedProfile = profile.copyWith(gifts: updatedGifts);
      await _profilesBox.put(profileId, updatedProfile);
    }
  }

  Future<void> deleteGift(String profileId, String giftId) async {
    final profile = _profilesBox.get(profileId);
    
    if (profile != null) {
      final updatedGifts = profile.gifts.where((g) => g.id != giftId).toList();
      final updatedProfile = profile.copyWith(gifts: updatedGifts);
      await _profilesBox.put(profileId, updatedProfile);
    }
  }
}
