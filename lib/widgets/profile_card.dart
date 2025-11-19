import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/profile.dart';
import '../utils/color_utils.dart';
import '../utils/date_utils.dart';
import '../screens/profile_screen.dart';
import '../services/notification_service.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_helper.dart';
import '../localization/app_localizations.dart';
import 'group_badge.dart';

/// Карточка профиля для отображения в списке
class ProfileCard extends StatelessWidget {
  final Profile profile;
  final Color primaryColor;
  final Future<void> Function() onProfileUpdated;
  final String? groupName; // Название группы для отображения

  const ProfileCard({
    super.key,
    required this.profile,
    required this.primaryColor,
    required this.onProfileUpdated,
    this.groupName,
  });

  @override
  Widget build(BuildContext context) {
    final daysUntil = daysUntilBirthday(profile.birthdate);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: context.cardShadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  profileId: profile.id,
                ),
              ),
            );
            await onProfileUpdated();
            // Обновляем уведомления после возврата
            final notificationService = NotificationService();
            await notificationService.scheduleAllNotifications();
          },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Аватар
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(profile.avatarColor),
                      getDarkerShade(profile.avatarColor),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(profile.avatarColor).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: profile.photoPath != null && File(profile.photoPath!).existsSync()
                    ? ClipOval(
                        child: Image.file(
                          File(profile.photoPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                profile.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text(
                          profile.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              // Информация
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            profile.name,
                            style: AppTextStyles.heading2(context).copyWith(
                              fontSize: 18,
                            ),
                          ),
                        ),
                        if (profile.groupId != null && groupName != null) ...[
                          const SizedBox(width: 8),
                          GroupBadge(
                            groupName: groupName!,
                            primaryColor: primaryColor,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.cake,
                          size: 16,
                          color: context.textColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          formatDateShort(profile.birthdate),
                          style: AppTextStyles.secondary(context).copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: context.textColor,
                          ),
                        ),
                      ],
                    ),
                    if (daysUntil <= 30 && daysUntil >= 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          daysUntil == 0
                              ? '🎉 ${AppLocalizations.of(context).today}'
                              : '${AppLocalizations.of(context).daysUntil} $daysUntil ${_getDaysText(daysUntil, AppLocalizations.of(context))}',
                          style: AppTextStyles.caption(context).copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  String _getDaysText(int days, AppLocalizations localizations) {
    final lastDigit = days % 10;
    final lastTwoDigits = days % 100;

    if (lastTwoDigits >= 11 && lastTwoDigits <= 14) {
      return localizations.days;
    } else if (lastDigit == 1) {
      return localizations.day;
    } else if (lastDigit >= 2 && lastDigit <= 4) {
      return localizations.days;
    } else {
      return localizations.days;
    }
  }
}

