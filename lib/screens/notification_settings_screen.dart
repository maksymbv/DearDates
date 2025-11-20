import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/notification_service.dart';
import '../services/theme_service.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_helper.dart';
import '../localization/app_localizations.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  final ThemeService _themeService = ThemeService();
  List<int> _reminderDays = [];
  bool _isLoading = true;

  final List<int> _availableDays = [1, 3, 7, 14, 30];
  
  Color get _primaryColor => Color(_themeService.primaryColor);

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
              padding: const EdgeInsets.all(20),
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
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? _primaryColor
                              : Theme.of(context).dividerColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          _getDayText(day, localizations),
                          style: AppTextStyles.body(context).copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? _primaryColor : context.textColor,
                          ),
                        ),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (_) => _toggleDay(day),
                          activeColor: _primaryColor,
                        ),
                        onTap: () => _toggleDay(day),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
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

  String _getDayText(int day, AppLocalizations localizations) {
    if (day == 1) {
      return '${localizations.daysBefore} 1 ${localizations.day}';
    }
    return '${localizations.daysBefore} $day ${localizations.days}';
  }
}

