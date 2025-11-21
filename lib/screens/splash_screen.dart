import 'package:flutter/material.dart';
import 'dart:async';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Инициализация анимации затухания
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Fade out анимация для логотипа (начинается с 1.0 - виден полностью)
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(_controller);

    // Через 1 секунду начинаем затухание
    Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        // Меняем анимацию на затухание
        setState(() {
          _fadeAnimation = Tween<double>(
            begin: 1.0,
            end: 0.0,
          ).animate(CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOut,
          ));
        });
        
        // Запускаем затухание
        _controller.forward();
        
        // После затухания переходим на главный экран
        Timer(const Duration(milliseconds: 400), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F6F6),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset(
            'logo_screen.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

