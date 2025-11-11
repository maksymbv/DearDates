import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Устанавливаем ориентацию только портретная
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Инициализируем локаль для intl
  Intl.defaultLocale = 'ru_RU';
  
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

  @override
  Widget build(BuildContext context) {
    final themeService = widget.themeService;
    final primaryColor = Color(themeService.primaryColor);
    final primaryDarkColor = Color(themeService.primaryDarkColor);
    
    return MaterialApp(
      title: 'DearDates',
      debugShowCheckedModeBanner: false,
      // Настройка локализации
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru', 'RU'),
        Locale('en', 'US'),
      ],
      locale: const Locale('ru', 'RU'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAF9F7),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F4F2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          shadowColor: Colors.black.withOpacity(0.05),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          backgroundColor: const Color(0xFFFAF9F7),
          foregroundColor: Colors.grey[600],
          centerTitle: true,
          titleSpacing: 0,
          toolbarHeight: 56,
          iconTheme: const IconThemeData(
            color: Colors.grey,
            size: 24,
          ),
          actionsIconTheme: const IconThemeData(
            color: Colors.grey,
            size: 24,
          ),
          titleTextStyle: const TextStyle(
            color: Color(0xFF2E2E2E),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            splashFactory: NoSplash.splashFactory,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            splashFactory: NoSplash.splashFactory,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            splashFactory: NoSplash.splashFactory,
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
              // Убираем все overlay эффекты для всех состояний, включая hover
              return Colors.transparent;
            }),
            backgroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
              // Убираем все фоновые эффекты для всех состояний, включая hover
              return Colors.transparent;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
              // Цвет иконки не меняется при любом состоянии, включая hover
              return Colors.grey[600];
            }),
            elevation: WidgetStateProperty.all(0),
            shadowColor: WidgetStateProperty.all(Colors.transparent),
            enableFeedback: false,
            visualDensity: VisualDensity.standard,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: WidgetStateProperty.all(Size.zero),
            padding: WidgetStateProperty.all(EdgeInsets.zero),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          splashColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          extendedSizeConstraints: BoxConstraints.tightFor(height: 56),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
