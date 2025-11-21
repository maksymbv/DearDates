import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../services/theme_service.dart';
import '../../themes/app_text_styles.dart';
import '../../themes/theme_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/app_card.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  final ThemeService _themeService = ThemeService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    await _themeService.loadTheme();
    setState(() {
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
          : ListenableBuilder(
              listenable: _themeService,
              builder: (context, _) {
                final currentTheme = _themeService.currentTheme;
                final isDarkMode = _themeService.isDarkMode;
                
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
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
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          leading: Icon(
                            isDarkMode ? LucideIcons.moon : LucideIcons.sun,
                            size: 24,
                            color: context.iconColor,
                          ),
                          title: Text(
                            isDarkMode ? localizations.darkTheme : localizations.lightTheme,
                            style: AppTextStyles.body(context).copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Switch(
                            value: isDarkMode,
                            onChanged: (_) => _toggleBrightness(),
                            activeColor: Theme.of(context).colorScheme.primary,
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
                        final isSelected = currentTheme == theme;
                        final primaryColor = Color(theme.primaryColor);
                        
                        return AppCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.zero,
                          border: isSelected
                              ? Border.all(
                                  color: primaryColor,
                                  width: 2,
                                )
                              : null,
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
                );
              },
            ),
    );
  }
}

