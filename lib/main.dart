import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';
import 'localization/app_localizations.dart';
import 'screens/home_screen.dart';
import 'theme/app_colors.dart';
import 'models/profile.dart';
import 'models/group.dart';
import 'adapters/date_time_adapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Устанавливаем ориентацию только портретная
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Инициализируем Hive
  await Hive.initFlutter();
  
  // Регистрируем адаптеры
  Hive.registerAdapter(DateTimeAdapter());
  Hive.registerAdapter(ProfileAdapter());
  Hive.registerAdapter(GiftAdapter());
  Hive.registerAdapter(GroupAdapter());
  
  // Открываем боксы
  await Hive.openBox<Profile>('profiles');
  await Hive.openBox<Group>('groups');
  
  // Загружаем тему
  final themeService = ThemeService();
  await themeService.loadTheme();
  
  // Инициализируем уведомления
  try {
    final notificationService = NotificationService();
    await notificationService.initialize();
  } catch (e) {
    // Игнорируем ошибки инициализации уведомлений
    debugPrint('Failed to initialize notifications: $e');
  }
  
  runApp(MyApp(themeService: themeService));
}

class MyApp extends StatefulWidget {
  final ThemeService themeService;
  
  MyApp({super.key, required this.themeService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Слушаем изменения темы
    widget.themeService.addListener(_onThemeChanged);
  }
  
  @override
  void dispose() {
    widget.themeService.removeListener(_onThemeChanged);
    super.dispose();
  }
  
  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // Общие настройки для InputDecoration
  InputDecorationTheme _buildInputDecorationTheme(Color primaryColor, bool isDark) {
    final colors = isDark ? AppColorScheme.dark() : AppColorScheme.light();
    return InputDecorationTheme(
      filled: true,
      fillColor: colors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? Colors.red[700]! : Colors.red[300]!,
          width: 1,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.border, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? Colors.red[600]! : Colors.red[400]!,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: TextStyle(
        color: colors.secondaryText,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: isDark ? Colors.white.withOpacity(0.6) : Colors.grey[400]!,
        fontSize: 16,
      ),
    );
  }

  // Общие настройки для кнопок
  ButtonStyle _buildButtonStyle(Color primaryColor) {
    return ButtonStyle(
      splashFactory: InkRipple.splashFactory,
      overlayColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return primaryColor.withOpacity(0.1);
        }
        return Colors.transparent;
      }),
    );
  }

  // Настройки для IconButton
  IconButtonThemeData _buildIconButtonTheme(bool isDark) {
    final colors = isDark ? AppColorScheme.dark() : AppColorScheme.light();
    return IconButtonThemeData(
      style: ButtonStyle(
        splashFactory: InkRipple.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        backgroundColor: WidgetStateProperty.all(Colors.transparent),
        foregroundColor: WidgetStateProperty.all(colors.icon),
        elevation: WidgetStateProperty.all(0),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        enableFeedback: true,
        visualDensity: VisualDensity.standard,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: WidgetStateProperty.all(Size.zero),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
      ),
    );
  }

  // Построение темы (объединенный метод)
  ThemeData _buildTheme(Color primaryColor, Color primaryDarkColor, bool isDark) {
    final colors = isDark ? AppColorScheme.dark() : AppColorScheme.light();
    final opacity = isDark ? 0.2 : 0.1;
    
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ).copyWith(
        surface: colors.card,
        onSurface: colors.text,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
      ),
      useMaterial3: true,
      extensions: [colors],
      scaffoldBackgroundColor: colors.background,
      inputDecorationTheme: _buildInputDecorationTheme(primaryColor, isDark),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: colors.card,
        shadowColor: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: colors.background,
        foregroundColor: colors.icon,
        centerTitle: true,
        titleSpacing: 0,
        toolbarHeight: 56,
        iconTheme: IconThemeData(color: colors.icon, size: 24),
        actionsIconTheme: IconThemeData(color: colors.icon, size: 24),
        titleTextStyle: TextStyle(
          color: colors.text,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
      splashColor: primaryColor.withOpacity(opacity),
      highlightColor: primaryColor.withOpacity(opacity * 0.5),
      hoverColor: primaryColor.withOpacity(opacity * 0.5),
      focusColor: primaryColor.withOpacity(opacity),
      splashFactory: InkRipple.splashFactory,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _buildButtonStyle(primaryColor).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withOpacity(0.2);
            }
            return Colors.transparent;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(style: _buildButtonStyle(primaryColor)),
      textButtonTheme: TextButtonThemeData(style: _buildButtonStyle(primaryColor)),
      iconButtonTheme: _buildIconButtonTheme(isDark),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        splashColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        extendedSizeConstraints: BoxConstraints.tightFor(height: 56),
      ),
      textTheme: isDark ? const TextTheme(
        displayLarge: TextStyle(color: Colors.white),
        displayMedium: TextStyle(color: Colors.white),
        displaySmall: TextStyle(color: Colors.white),
        headlineLarge: TextStyle(color: Colors.white),
        headlineMedium: TextStyle(color: Colors.white),
        headlineSmall: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        titleSmall: TextStyle(color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white),
        labelLarge: TextStyle(color: Colors.white),
        labelMedium: TextStyle(color: Colors.white),
        labelSmall: TextStyle(color: Colors.white),
      ) : null,
    );
  }

  ThemeData _buildLightTheme(Color primaryColor, Color primaryDarkColor) {
    return _buildTheme(primaryColor, primaryDarkColor, false);
  }

  ThemeData _buildDarkTheme(Color primaryColor, Color primaryDarkColor) {
    return _buildTheme(primaryColor, primaryDarkColor, true);
  }

  @override
  Widget build(BuildContext context) {
    final themeService = widget.themeService;
    final primaryColor = Color(themeService.primaryColor);
    final primaryDarkColor = Color(themeService.primaryDarkColor);
    
    return MaterialApp(
      title: 'DearDates',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ru', 'RU'),
        Locale('uk', 'UA'),
      ],
      theme: _buildLightTheme(primaryColor, primaryDarkColor),
      darkTheme: _buildDarkTheme(primaryColor, primaryDarkColor),
      themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}
