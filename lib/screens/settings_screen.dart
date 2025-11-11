import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/notification_service.dart';
import '../services/theme_service.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
    _loadSettings();
  }
  
  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }
  
  void _onThemeChanged() {
    if (mounted) {
      setState(() {
        _currentTheme = _themeService.currentTheme;
      });
    }
  }

  Future<void> _loadSettings() async {
    final days = await _notificationService.getReminderDays();
    await _themeService.loadTheme();
    setState(() {
      _reminderDays = List.from(days);
      _currentTheme = _themeService.currentTheme;
      _isLoading = false;
    });
  }
  
  String _getThemeText() {
    return _currentTheme.displayName;
  }

  String _getReminderDaysText() {
    if (_reminderDays.isEmpty) {
      return 'Не выбрано';
    }
    _reminderDays.sort();
    if (_reminderDays.length == 1) {
      return 'За ${_reminderDays.first} ${_getDayText(_reminderDays.first)}';
    }
    final daysList = _reminderDays.map((d) => '$d').join(', ');
    return 'За $daysList дней';
  }

  String _getDayText(int day) {
    if (day == 1) {
      return 'день';
    }
    if (day >= 2 && day <= 4) {
      return 'дня';
    }
    return 'дней';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        centerTitle: true,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.grey),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              mouseCursor: SystemMouseCursors.basic,
              tooltip: '',
            ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Блок уведомлений
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Row(
                              children: [
                                const Text(
                                  'Уведомления',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF2E2E2E),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _getReminderDaysText(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                            trailing: Icon(
                              LucideIcons.chevronRight,
                              color: Colors.grey[600],
                              size: 18,
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
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Row(
                              children: [
                                const Text(
                                  'Тема',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF2E2E2E),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _getThemeText(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                            trailing: Icon(
                              LucideIcons.chevronRight,
                              color: Colors.grey[600],
                              size: 18,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Made by Max Baranov with ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        '❤️',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

