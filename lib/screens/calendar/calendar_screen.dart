import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/profile.dart';
import '../../models/group.dart';
import '../../services/storage_service.dart';
import '../../services/group_service.dart';
import '../../themes/app_text_styles.dart';
import '../../themes/theme_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/profile_card.dart';
import '../../widgets/bottom_nav_bar.dart';

class CalendarScreen extends StatefulWidget {
  final bool showBottomNav;
  
  const CalendarScreen({super.key, this.showBottomNav = true});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final StorageService _storageService = StorageService();
  final GroupService _groupService = GroupService();
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  List<Profile> _profiles = [];
  List<Group> _groups = [];
  bool _isLoading = true;

  Color _getPrimaryColor(BuildContext context) => Theme.of(context).colorScheme.primary;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);
    final profiles = await _storageService.loadProfiles();
    final groups = await _groupService.getAllGroups();
    
    if (!mounted) return;
    setState(() {
      _profiles = profiles;
      _groups = groups;
      _isLoading = false;
    });
  }

  String _getGroupName(String? groupId) {
    if (groupId == null) return '';
    try {
      return _groups.firstWhere((g) => g.id == groupId).name;
    } catch (e) {
      return '';
    }
  }

  List<Profile> _getProfilesForDay(DateTime day) {
    return _profiles.where((profile) {
      final birthdate = profile.birthdate;
      return birthdate.month == day.month && birthdate.day == day.day;
    }).toList();
  }

  List<Profile> _getProfilesForMonth(DateTime month) {
    return _profiles.where((profile) {
      final birthdate = profile.birthdate;
      // Проверяем только месяц, независимо от года
      return birthdate.month == month.month;
    }).toList()
      ..sort((a, b) {
        // Сортируем по дню месяца
        return a.birthdate.day.compareTo(b.birthdate.day);
      });
  }

  bool _hasBirthdayOnDay(DateTime day) {
    return _getProfilesForDay(day).isNotEmpty;
  }

  void _goToToday() {
    final today = DateTime.now();
    setState(() {
      _focusedDay = today;
      _selectedDay = today;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profilesInMonth = _getProfilesForMonth(_focusedDay);

    return Scaffold(
      body: Stack(
        children: [
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: _getPrimaryColor(context).withOpacity(0.7),
                  ),
                )
              : Column(
                  children: [
                    // Календарь
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                      child: TableCalendar(
                    firstDay: DateTime(DateTime.now().year - 5, 1, 1),
                    lastDay: DateTime(DateTime.now().year + 5, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                    calendarFormat: CalendarFormat.month,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Month',
                    },
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: AppTextStyles.heading2(context).copyWith(
                        fontSize: 18,
                      ),
                      leftChevronIcon: Icon(
                        LucideIcons.chevronLeft,
                        color: context.iconColor,
                        size: 24,
                      ),
                      rightChevronIcon: Icon(
                        LucideIcons.chevronRight,
                        color: context.iconColor,
                        size: 24,
                      ),
                      headerPadding: const EdgeInsets.only(bottom: 12, top: 8),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: AppTextStyles.caption(context).copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      weekendStyle: AppTextStyles.caption(context).copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getPrimaryColor(context),
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      todayDecoration: BoxDecoration(
                        color: _getPrimaryColor(context).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: TextStyle(
                        color: _getPrimaryColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: _getPrimaryColor(context),
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      markerDecoration: BoxDecoration(
                        color: _getPrimaryColor(context),
                        shape: BoxShape.circle,
                      ),
                      markersMaxCount: 3,
                      defaultTextStyle: AppTextStyles.body(context).copyWith(
                        fontSize: 16,
                      ),
                      weekendTextStyle: AppTextStyles.body(context).copyWith(
                        fontSize: 16,
                        color: _getPrimaryColor(context).withOpacity(0.7),
                      ),
                    ),
                    eventLoader: (day) {
                      return _hasBirthdayOnDay(day) ? ['birthday'] : [];
                    },
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        if (events.isEmpty) return null;
                        return Positioned(
                          bottom: 4,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _getPrimaryColor(context),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                    ),
                    // Текст "Сегодня"
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: _goToToday,
                          child: Text(
                            AppLocalizations.of(context).today,
                            style: AppTextStyles.body(context).copyWith(
                              fontSize: 14,
                              color: _getPrimaryColor(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                // Список профилей с ДР в этом месяце
                if (profilesInMonth.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      AppLocalizations.of(context).birthdays,
                      style: AppTextStyles.heading2(context).copyWith(
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Expanded(
                  child: profilesInMonth.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.cake,
                                size: 48,
                                color: context.secondaryTextColor.withOpacity(0.4),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                AppLocalizations.of(context).noBirthdaysInMonth,
                                style: AppTextStyles.secondary(context),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 110,
                          ),
                          itemCount: profilesInMonth.length,
                          itemBuilder: (context, index) {
                            final profile = profilesInMonth[index];
                            return ProfileCard(
                              key: ValueKey(profile.id),
                              profile: profile,
                              primaryColor: _getPrimaryColor(context),
                              onProfileUpdated: _loadProfiles,
                              groupName: _getGroupName(profile.groupId),
                            );
                          },
                        ),
                  ),
                ],
              ),
          // Floating меню снизу
          if (widget.showBottomNav)
            BottomNavBar(
              currentPage: NavPage.calendar,
              primaryColor: _getPrimaryColor(context),
              onProfileAdded: _loadProfiles,
            ),
        ],
      ),
    );
  }
}

