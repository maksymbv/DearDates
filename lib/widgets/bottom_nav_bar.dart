import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../screens/home/home_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/profile/add_profile_screen.dart';
import '../themes/theme_helper.dart';

enum NavPage { home, calendar }

/// Статичный вариант нижнего меню для использования с IndexedStack
class BottomNavBarStatic extends StatelessWidget {
  final int currentIndex;
  final Function(int) onPageChanged;
  final Color primaryColor;

  const BottomNavBarStatic({
    super.key,
    required this.currentIndex,
    required this.onPageChanged,
    required this.primaryColor,
  });

  Widget _buildNavButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          splashColor: primaryColor.withOpacity(0.1),
          highlightColor: Colors.transparent,
          child: Icon(
            icon,
            color: isActive ? primaryColor : context.iconColor.withOpacity(0.5),
            size: 24,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 20,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Кнопка Календарь
              _buildNavButton(
                context: context,
                icon: LucideIcons.calendar,
                isActive: currentIndex == 1,
                onTap: () => onPageChanged(1),
              ),
              const SizedBox(width: 32),
              // Центральная кнопка +
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddProfileScreen(),
                        ),
                      );
                    },
                    customBorder: const CircleBorder(),
                    splashColor: Colors.white.withOpacity(0.2),
                    highlightColor: Colors.transparent,
                    child: const Icon(
                      LucideIcons.plus,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 32),
              // Кнопка Список (Home)
              _buildNavButton(
                context: context,
                icon: LucideIcons.list,
                isActive: currentIndex == 0,
                onTap: () => onPageChanged(0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final NavPage currentPage;
  final Color primaryColor;
  final VoidCallback? onProfileAdded;

  const BottomNavBar({
    super.key,
    required this.currentPage,
    required this.primaryColor,
    this.onProfileAdded,
  });

  Widget _buildNavButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          splashColor: primaryColor.withOpacity(0.1),
          highlightColor: Colors.transparent,
          child: Icon(
            icon,
            color: isActive ? primaryColor : context.iconColor.withOpacity(0.5),
            size: 24,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 20,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Кнопка Календарь
              _buildNavButton(
                context: context,
                icon: LucideIcons.calendar,
                isActive: currentPage == NavPage.calendar,
                onTap: () {
                  if (currentPage != NavPage.calendar) {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const CalendarScreen(showBottomNav: true),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(width: 32),
              // Центральная кнопка +
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddProfileScreen(),
                        ),
                      );
                      if (onProfileAdded != null) {
                        onProfileAdded!();
                      }
                    },
                    customBorder: const CircleBorder(),
                    splashColor: Colors.white.withOpacity(0.2),
                    highlightColor: Colors.transparent,
                    child: const Icon(
                      LucideIcons.plus,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 32),
              // Кнопка Список (Home)
              _buildNavButton(
                context: context,
                icon: LucideIcons.list,
                isActive: currentPage == NavPage.home,
                onTap: () {
                  if (currentPage != NavPage.home) {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(showBottomNav: true),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

