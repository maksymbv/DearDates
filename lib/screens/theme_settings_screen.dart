import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/theme_service.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_helper.dart';
import '../localization/app_localizations.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  final ThemeService _themeService = ThemeService();
  AppTheme _currentTheme = AppTheme.pink;
  bool _isDarkMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
    _loadTheme();
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
        _isDarkMode = _themeService.isDarkMode;
      });
    }
  }

  Future<void> _loadTheme() async {
    await _themeService.loadTheme();
    setState(() {
      _currentTheme = _themeService.currentTheme;
      _isDarkMode = _themeService.isDarkMode;
      _isLoading = false;
    });
  }

  Future<void> _changeTheme(AppTheme theme) async {
    await _themeService.setTheme(theme);
  }
  
  Future<void> _toggleBrightness() async {
    await _themeService.toggleBrightness();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.theme,
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
                  // Переключатель светлая/темная тема
                  Text(
                    localizations.displayMode,
                    style: AppTextStyles.heading2(context).copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.selectLightOrDark,
                    style: AppTextStyles.secondary(context).copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: context.cardShadows,
                    ),
                    child: ListTile(
                      leading: Icon(
                        _isDarkMode ? LucideIcons.moon : LucideIcons.sun,
                        size: 24,
                        color: context.iconColor,
                      ),
                      title: Text(
                        _isDarkMode ? localizations.darkTheme : localizations.lightTheme,
                        style: AppTextStyles.body(context).copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Switch(
                        value: _isDarkMode,
                        onChanged: (_) => _toggleBrightness(),
                        activeColor: Color(_themeService.primaryColor),
                      ),
                      onTap: () => _toggleBrightness(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Выбор акцента
                  Text(
                    localizations.accentColor,
                    style: AppTextStyles.heading2(context).copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.selectColorScheme,
                    style: AppTextStyles.secondary(context).copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  ...AppTheme.values.map((theme) {
                    final isSelected = _currentTheme == theme;
                    final primaryColor = Color(theme.primaryColor);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: context.cardShadows,
                        border: isSelected
                            ? Border.all(
                                color: primaryColor,
                                width: 2,
                              )
                            : null,
                      ),
                      child: ListTile(
                        title: Text(
                          theme == AppTheme.pink ? localizations.pink : localizations.blue,
                          style: AppTextStyles.body(context).copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? primaryColor : context.textColor,
                          ),
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                LucideIcons.check,
                                color: primaryColor,
                                size: 24,
                              )
                            : null,
                        onTap: () => _changeTheme(theme),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}

