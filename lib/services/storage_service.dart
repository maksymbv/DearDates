import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';
import 'notification_service.dart';
import 'photo_service.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  
  factory StorageService() => _instance;
  StorageService._internal();
  
  static const String _profilesKey = 'profiles';

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
    final prefs = await SharedPreferences.getInstance();
    final profilesJson = prefs.getStringList(_profilesKey);
    
    if (profilesJson == null || profilesJson.isEmpty) {
      return [];
    }

    final profiles = profilesJson
        .map((json) {
          final data = jsonDecode(json) as Map<String, dynamic>;
          // Если у профиля нет avatarColor, генерируем случайный
          if (!data.containsKey('avatarColor')) {
            data['avatarColor'] = generatePastelColor();
          }
          return Profile.fromJson(data);
        })
        .toList();

    // Сохраняем обновленные профили, если были изменения
    final needsSave = profilesJson.any((json) {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return !data.containsKey('avatarColor');
    });

    if (needsSave) {
      await saveProfiles(profiles);
    }

    return profiles;
  }

  Future<void> saveProfiles(List<Profile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    final profilesJson = profiles
        .map((profile) => jsonEncode(profile.toJson()))
        .toList();
    
    await prefs.setStringList(_profilesKey, profilesJson);
  }

  Future<void> addProfile(Profile profile) async {
    final profiles = await loadProfiles();
    profiles.add(profile);
    await saveProfiles(profiles);
    
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
    final profiles = await loadProfiles();
    final index = profiles.indexWhere((p) => p.id == profile.id);
    
    if (index != -1) {
      final oldProfile = profiles[index];
      
      // Удаляем старое фото, если оно было изменено или удалено
      if (oldProfile.photoPath != null && oldProfile.photoPath != profile.photoPath) {
        final photoService = PhotoService();
        await photoService.deletePhoto(oldProfile.photoPath);
      }
      
      profiles[index] = profile;
      await saveProfiles(profiles);
      
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
    final profiles = await loadProfiles();
    final profileToDelete = profiles.firstWhere(
      (p) => p.id == profileId,
      orElse: () => throw Exception('Profile not found'),
    );
    
    // Удаляем фото профиля, если оно есть
    if (profileToDelete.photoPath != null) {
      final photoService = PhotoService();
      await photoService.deletePhoto(profileToDelete.photoPath);
    }
    
    profiles.removeWhere((p) => p.id == profileId);
    await saveProfiles(profiles);
    
    // Отменяем уведомления для удаленного профиля
    final notificationService = NotificationService();
    final reminderDays = await notificationService.getReminderDays();
    await notificationService.cancelProfileNotifications(profileId, reminderDays);
  }

  Future<void> addGift(String profileId, Gift gift) async {
    final profiles = await loadProfiles();
    final profileIndex = profiles.indexWhere((p) => p.id == profileId);
    
    if (profileIndex != -1) {
      final profile = profiles[profileIndex];
      final updatedGifts = List<Gift>.from(profile.gifts)..add(gift);
      profiles[profileIndex] = profile.copyWith(gifts: updatedGifts);
      await saveProfiles(profiles);
    }
  }

  Future<void> updateGift(String profileId, Gift gift) async {
    final profiles = await loadProfiles();
    final profileIndex = profiles.indexWhere((p) => p.id == profileId);
    
    if (profileIndex != -1) {
      final profile = profiles[profileIndex];
      final updatedGifts = profile.gifts.map((g) {
        return g.id == gift.id ? gift : g;
      }).toList();
      profiles[profileIndex] = profile.copyWith(gifts: updatedGifts);
      await saveProfiles(profiles);
    }
  }

  Future<void> deleteGift(String profileId, String giftId) async {
    final profiles = await loadProfiles();
    final profileIndex = profiles.indexWhere((p) => p.id == profileId);
    
    if (profileIndex != -1) {
      final profile = profiles[profileIndex];
      final updatedGifts = profile.gifts.where((g) => g.id != giftId).toList();
      profiles[profileIndex] = profile.copyWith(gifts: updatedGifts);
      await saveProfiles(profiles);
    }
  }
}

