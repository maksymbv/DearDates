import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/notification_service.dart';
import '../../services/theme_service.dart';
import '../../l10n/app_localizations.dart';
import '../../themes/app_text_styles.dart';
import '../../themes/theme_helper.dart';
import '../../utils/date_utils.dart';
import '../../widgets/app_card.dart';
import 'notification_settings_screen.dart';
import 'theme_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  final ThemeService _themeService = ThemeService();
  List<int> _reminderDays = [];
  AppTheme _currentTheme = AppTheme.pink;
  bool _isDarkMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final days = await _notificationService.getReminderDays();
    await _themeService.loadTheme();
    setState(() {
      _reminderDays = List.from(days);
      _currentTheme = _themeService.currentTheme;
      _isDarkMode = _themeService.isDarkMode;
      _isLoading = false;
    });
  }
  
  String _getThemeText() {
    final localizations = AppLocalizations.of(context);
    final brightness = _isDarkMode ? localizations.dark : localizations.light;
    final color = _currentTheme == AppTheme.pink ? localizations.pink : localizations.blue;
    return '$brightness $color';
  }
  

  String _getReminderDaysText() {
    final localizations = AppLocalizations.of(context);
    
    if (_reminderDays.isEmpty) {
      return localizations.notSelected;
    }
    _reminderDays.sort();
    if (_reminderDays.length == 1) {
      return '${localizations.daysBefore} ${_reminderDays.first} ${pluralDays(_reminderDays.first, localizations)}';
    }
    final daysList = _reminderDays.map((d) => '$d').join(', ');
    return '${localizations.daysBefore} $daysList ${localizations.days}';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.settings,
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
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                      bottom: MediaQuery.of(context).padding.bottom + 20,
                    ),
                    child: Column(
                      children: [
                        // Блок уведомлений
                        AppCard(
                          padding: EdgeInsets.zero,
                          child: ListTile(
                            leading: Icon(
                              LucideIcons.bell,
                              size: 24,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: Row(
                              children: [
                                Text(
                                  localizations.notifications,
                                  style: AppTextStyles.body(context).copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _getReminderDaysText(),
                                  style: AppTextStyles.caption(context),
                                ),
                              ],
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NotificationSettingsScreen(),
                                ),
                              );
                              // Обновляем настройки после возврата
                              if (mounted) {
                                await _loadSettings();
                              }
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Блок темы
                        AppCard(
                          padding: EdgeInsets.zero,
                          child: ListTile(
                            leading: Icon(
                              LucideIcons.palette,
                              size: 24,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: Row(
                              children: [
                                Text(
                                  localizations.theme,
                                  style: AppTextStyles.body(context).copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _getThemeText(),
                                  style: AppTextStyles.caption(context),
                                ),
                              ],
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ThemeSettingsScreen(),
                                ),
                              );
                              // Обновляем настройки после возврата
                              if (mounted) {
                                await _loadSettings();
                              }
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Подпись внизу
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 12,
                        color: context.secondaryTextColor,
                      ),
                      children: [
                        TextSpan(text: localizations.madeBy),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

