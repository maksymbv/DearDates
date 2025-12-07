import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'calendar/calendar_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../themes/theme_helper.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  Color _getPrimaryColor(BuildContext context) => Theme.of(context).colorScheme.primary;

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: const [
              HomeScreen(showBottomNav: false),
              CalendarScreen(showBottomNav: false),
            ],
          ),
          BottomNavBarStatic(
            currentIndex: _currentIndex,
            onPageChanged: _onPageChanged,
            primaryColor: _getPrimaryColor(context),
          ),
        ],
      ),
    );
  }
}

