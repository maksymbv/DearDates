import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../utils/date_utils.dart' show daysUntilBirthday, pluralDays, formatDateShort;
import '../screens/profile/profile_screen.dart';
import '../themes/app_text_styles.dart';
import '../themes/theme_helper.dart';
import '../l10n/app_localizations.dart';
import 'avatar.dart';
import 'group_badge.dart';

/// Profile card for displaying in the list
class ProfileCard extends StatelessWidget {
  final Profile profile;
  final Color primaryColor;
  final Future<void> Function() onProfileUpdated;
  final String? groupName; // Name of the group for displaying

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
            // Уведомления автоматически обновляются в StorageService.updateProfile()
          },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              AvatarWidget(
                photoPath: profile.photoPath,
                avatarColor: profile.avatarColor,
                name: profile.name,
                size: 64,
                fontSize: 28,
              ),
              const SizedBox(width: 16),
              // Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      profile.name,
                      style: AppTextStyles.heading2(context).copyWith(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatDateShort(profile.birthdate, Localizations.localeOf(context)),
                      style: AppTextStyles.secondary(context).copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.textColor,
                      ),
                    ),
                    if (profile.groupId != null && groupName != null) ...[
                      const SizedBox(height: 6),
                      GroupBadge(
                        groupName: groupName!,
                        primaryColor: primaryColor,
                      ),
                    ],
                  ],
                ),
              ),
              // Counter of days in the center
              if (daysUntil <= 30 && daysUntil >= 0) ...[
                const SizedBox(width: 12),
                Text(
                  daysUntil == 0
                      ? '🎉 ${AppLocalizations.of(context).today}'
                      : '$daysUntil ${pluralDays(daysUntil, AppLocalizations.of(context))}',
                  style: AppTextStyles.caption(context).copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ],
            ],
          ),
        ),
        ),
      ),
    );
  }
}

