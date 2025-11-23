import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../services/notification_service.dart';
import '../../themes/app_text_styles.dart';
import '../../themes/theme_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/date_utils.dart';
import '../../widgets/app_card.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<int> _reminderDays = [];
  bool _isLoading = true;

  final List<int> _availableDays = [1, 3, 7, 14, 30];
  
  Color _getPrimaryColor(BuildContext context) => Theme.of(context).colorScheme.primary;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final days = await _notificationService.getReminderDays();
    setState(() {
      _reminderDays = List.from(days);
      _isLoading = false;
    });
  }

  Future<void> _toggleDay(int day) async {
    setState(() {
      if (_reminderDays.contains(day)) {
        _reminderDays.remove(day);
      } else {
        _reminderDays.add(day);
        _reminderDays.sort();
      }
    });

    // Сохраняем настройки
    await _notificationService.setReminderDays(_reminderDays);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.notificationSettings,
          style: AppTextStyles.heading2(context),
        ),
        centerTitle: true,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
            child: IconButton(
              icon: Icon(LucideIcons.arrowLeft, color: context.iconColor, size: 24),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              mouseCursor: SystemMouseCursors.basic,
              tooltip: '',
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).padding.bottom + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.reminderDaysTitle,
                    style: AppTextStyles.heading2(context).copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.reminderDaysDescription,
                    style: AppTextStyles.secondary(context).copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  ..._availableDays.map((day) {
                    final isSelected = _reminderDays.contains(day);
                    return AppCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        title: Text(
                          '${localizations.daysBefore} $day ${pluralDays(day, localizations)}',
                          style: AppTextStyles.body(context).copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? _getPrimaryColor(context) : context.textColor,
                          ),
                        ),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (_) => _toggleDay(day),
                          activeColor: _getPrimaryColor(context),
                        ),
                        onTap: () => _toggleDay(day),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  AppCard(
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.info,
                          size: 24,
                          color: context.iconColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            localizations.birthdayNotificationInfo,
                            style: AppTextStyles.caption(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

