import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/profile.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/theme_service.dart';
import '../utils/date_utils.dart';
import 'add_profile_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

// Типы сортировки
enum SortType {
  daysUntil, // По количеству дней до дня рождения (по умолчанию)
  name, // По имени
  birthdate, // По дате рождения
}

extension SortTypeExtension on SortType {
  String get displayName {
    switch (this) {
      case SortType.daysUntil:
        return 'По дням до дня рождения';
      case SortType.name:
        return 'По имени';
      case SortType.birthdate:
        return 'По дате рождения';
    }
  }
}

// Получение более темного оттенка цвета для градиента
Color _getDarkerShade(int color) {
  final baseColor = Color(color);
  return Color.fromRGBO(
    (baseColor.red * 0.85).round().clamp(0, 255),
    (baseColor.green * 0.85).round().clamp(0, 255),
    (baseColor.blue * 0.85).round().clamp(0, 255),
    1.0,
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  final ThemeService _themeService = ThemeService();
  List<Profile> _profiles = [];
  List<Profile> _filteredProfiles = [];
  bool _isLoading = true;
  SortType _sortType = SortType.daysUntil;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  bool _isCalendarView = false;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  static const String _sortTypeKey = 'sort_type';
  
  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
    _initializeAndLoad();
  }
  
  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
  
  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }
  
  Color get _primaryColor => Color(_themeService.primaryColor);
  Color get _primaryDarkColor => Color(_themeService.primaryDarkColor);

  Future<void> _initializeAndLoad() async {
    // Загружаем сохраненный тип сортировки
    await _loadSortType();
    
    // Инициализируем уведомления и планируем их
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();
      await notificationService.scheduleAllNotifications();
    } catch (e) {
      // Игнорируем ошибки инициализации уведомлений (например, на macOS может не быть разрешений)
      debugPrint('Failed to initialize notifications: $e');
    }
    
    // Загружаем профили
    await _loadProfiles();
  }

  Future<void> _loadSortType() async {
    final prefs = await SharedPreferences.getInstance();
    final sortTypeIndex = prefs.getInt(_sortTypeKey);
    if (sortTypeIndex != null && sortTypeIndex >= 0 && sortTypeIndex < SortType.values.length) {
      setState(() {
        _sortType = SortType.values[sortTypeIndex];
      });
    }
  }

  Future<void> _saveSortType(SortType sortType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sortTypeKey, sortType.index);
  }

  void _sortProfiles(List<Profile> profiles) {
    switch (_sortType) {
      case SortType.daysUntil:
        // Сортировка по количеству дней до дня рождения
        profiles.sort((a, b) {
          final daysA = daysUntilBirthday(a.birthdate);
          final daysB = daysUntilBirthday(b.birthdate);
          return daysA.compareTo(daysB);
        });
        break;
      case SortType.name:
        // Сортировка по имени (алфавитная)
        profiles.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortType.birthdate:
        // Сортировка по дате рождения (сначала те, кто родился раньше в году)
        profiles.sort((a, b) {
          // Сравниваем месяц, затем день
          if (a.birthdate.month != b.birthdate.month) {
            return a.birthdate.month.compareTo(b.birthdate.month);
          }
          return a.birthdate.day.compareTo(b.birthdate.day);
        });
        break;
    }
  }

  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);
    final profiles = await _storageService.loadProfiles();
    
    // Применяем сортировку
    _sortProfiles(profiles);

    setState(() {
      _profiles = profiles;
      // Сохраняем текущий поисковый запрос и применяем фильтрацию
      if (_isSearching && _searchController.text.isNotEmpty) {
        _filterProfiles(_searchController.text);
      } else {
        _filteredProfiles = List.from(profiles);
      }
      _isLoading = false;
    });
  }

  void _filterProfiles(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProfiles = List.from(_profiles);
      } else {
        final lowerQuery = query.toLowerCase().trim();
        _filteredProfiles = _profiles.where((profile) {
          // Поиск по имени
          final nameMatch = profile.name.toLowerCase().contains(lowerQuery);
          
          // Поиск по заметкам
          final notesMatch = profile.notes != null && 
              profile.notes!.toLowerCase().contains(lowerQuery);
          
          // Поиск по идеям подарков
          final giftsMatch = profile.gifts.any((gift) => 
              gift.idea.toLowerCase().contains(lowerQuery));
          
          return nameMatch || notesMatch || giftsMatch;
        }).toList();
      }
      // Применяем сортировку к отфильтрованным результатам
      _sortProfiles(_filteredProfiles);
    });
  }

  Future<void> _changeSortType(SortType newSortType) async {
    if (_sortType == newSortType) return;
    
    setState(() {
      _sortType = newSortType;
    });
    
    // Сохраняем выбор
    await _saveSortType(newSortType);
    
    // Применяем сортировку
    _sortProfiles(_profiles);
    if (_isSearching && _searchController.text.isNotEmpty) {
      _filterProfiles(_searchController.text);
    } else {
      setState(() {
        _filteredProfiles = List.from(_profiles);
      });
    }
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
      // Отключаем календарный вид при начале поиска
      _isCalendarView = false;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _filteredProfiles = List.from(_profiles);
    });
    _searchFocusNode.unfocus();
  }

  // Получение профилей с днем рождения в указанный день
  List<Profile> _getProfilesForDate(DateTime date) {
    return _profiles.where((profile) {
      return profile.birthdate.month == date.month &&
          profile.birthdate.day == date.day;
    }).toList();
  }


  void _toggleCalendarView() {
    setState(() {
      _isCalendarView = !_isCalendarView;
      if (_isCalendarView) {
        // Переключаемся на календарь - отключаем поиск
        _isSearching = false;
        _searchController.clear();
        _filteredProfiles = List.from(_profiles);
        _searchFocusNode.unfocus();
        _selectedDay = DateTime.now();
        _focusedDay = DateTime.now();
      }
    });
  }

  void _showSortMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Заголовок
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Сортировка',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(LucideIcons.x, size: 20, color: Colors.grey[600]),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // Варианты сортировки
              ...SortType.values.map((sortType) {
                final isSelected = _sortType == sortType;
                return ListTile(
                  title: Text(
                    sortType.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? _primaryColor : Colors.grey[800],
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          LucideIcons.check,
                          color: _primaryColor,
                          size: 20,
                        )
                      : null,
                  onTap: () {
                    _changeSortType(sortType);
                    Navigator.pop(context);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isCalendarView ? null : AppBar(
        title: _isSearching
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  autofocus: true,
                  style: const TextStyle(
                    color: Color(0xFF2E2E2E),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Поиск...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    filled: false,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: _filterProfiles,
                  onSubmitted: (_) {
                    _searchFocusNode.unfocus();
                  },
                ),
              )
            : null,
        centerTitle: false,
        titleSpacing: 0,
        leading: _isSearching || _isCalendarView
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: 20),
                child: IconButton(
                  icon: Icon(LucideIcons.arrowUpDown, color: Colors.grey[600]),
                  onPressed: () => _showSortMenu(context),
                  padding: EdgeInsets.zero,
                  mouseCursor: SystemMouseCursors.basic,
                  tooltip: '',
                ),
              ),
        actions: [
          if (_isSearching) ...[
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, child) {
                if (value.text.isNotEmpty) {
                  return IconButton(
                    icon: Icon(LucideIcons.x, size: 20, color: Colors.grey[600]),
                    onPressed: () {
                      _searchController.clear();
                      _filterProfiles('');
                    },
                    padding: EdgeInsets.zero,
                    mouseCursor: SystemMouseCursors.basic,
                    tooltip: '',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: IconButton(
                icon: Icon(LucideIcons.arrowLeft, size: 20, color: Colors.grey[600]),
                onPressed: _stopSearch,
                padding: EdgeInsets.zero,
                mouseCursor: SystemMouseCursors.basic,
                tooltip: '',
              ),
            ),
          ] else if (!_isCalendarView)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: IconButton(
                icon: Icon(LucideIcons.search, color: Colors.grey[600]),
                onPressed: _startSearch,
                padding: EdgeInsets.zero,
                mouseCursor: SystemMouseCursors.basic,
                tooltip: '',
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: _primaryColor.withOpacity(0.7),
                  ),
                )
              : _profiles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryColor.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              LucideIcons.cake,
                              size: 64,
                              color: _primaryColor.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Пока нет профилей',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Добавьте первый профиль!',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : _isCalendarView
                      ? _buildCalendarView()
                      : Column(
                      children: [
                        // Индикатор результатов поиска
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _searchController,
                          builder: (context, value, child) {
                            if (_isSearching && value.text.isNotEmpty) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F4F2),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[200]!,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      LucideIcons.search,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _filteredProfiles.isEmpty
                                          ? 'Ничего не найдено'
                                          : 'Найдено: ${_filteredProfiles.length}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        // Список профилей
                        Expanded(
                          child: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _searchController,
                            builder: (context, value, child) {
                              if (_filteredProfiles.isEmpty && _isSearching && value.text.isNotEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        LucideIcons.searchX,
                                        size: 64,
                                        color: Colors.grey[300],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Ничего не найдено',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Попробуйте изменить запрос',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return RefreshIndicator(
                                  onRefresh: _loadProfiles,
                                  color: _primaryColor,
                                  displacement: 40,
                                  triggerMode: RefreshIndicatorTriggerMode.onEdge,
                                  child: ListView.builder(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.only(
                                      left: 20,
                                      right: 20,
                                      top: 20,
                                      bottom: 20,
                                    ),
                                    itemCount: _filteredProfiles.length,
                                    itemBuilder: (context, index) {
                                      final profile = _filteredProfiles[index];
                                      final daysUntil = daysUntilBirthday(profile.birthdate);
                                      final age = getAge(profile.birthdate);

                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 16),
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
                                        child: GestureDetector(
                                          onTap: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ProfileScreen(
                                                  profileId: profile.id,
                                                ),
                                              ),
                                            );
                                            await _loadProfiles();
                                            // Обновляем уведомления после возврата
                                            final notificationService = NotificationService();
                                            await notificationService.scheduleAllNotifications();
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Row(
                                              children: [
                                                // Аватар
                                                Container(
                                                  width: 56,
                                                  height: 56,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Color(profile.avatarColor),
                                                        _getDarkerShade(profile.avatarColor),
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                    ),
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Color(profile.avatarColor).withOpacity(0.3),
                                                        blurRadius: 8,
                                                        offset: const Offset(0, 4),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      profile.name[0].toUpperCase(),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 24,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                // Информация
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        profile.name,
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.w600,
                                                          color: Color(0xFF2E2E2E),
                                                          letterSpacing: 0.2,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            LucideIcons.cake,
                                                            size: 14,
                                                            color: Colors.grey[600],
                                                          ),
                                                          const SizedBox(width: 6),
                                                          Text(
                                                            '${formatDate(profile.birthdate)} • $age ${_getAgeText(age)}',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.grey[600],
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      if (daysUntil <= 30 && daysUntil >= 0) ...[
                                                        const SizedBox(height: 8),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 4,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: _primaryColor.withOpacity(0.1),
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                          child: Text(
                                                            daysUntil == 0
                                                                ? '🎉 День рождения сегодня!'
                                                                : 'Через $daysUntil ${_getDaysText(daysUntil)}',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: _primaryColor,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                            },
                          ),
                        ),
                      ],
                    ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Левая часть - переключение между календарем и списком
              Expanded(
                child: Center(
                  child: IconButton(
                    icon: Icon(
                      _isCalendarView ? LucideIcons.list : LucideIcons.calendar,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                    onPressed: _toggleCalendarView,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
              // Центральная часть - кнопка добавления
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddProfileScreen(),
                    ),
                  );
                  await _loadProfiles();
                  // Обновляем уведомления после создания профиля
                  final notificationService = NotificationService();
                  await notificationService.scheduleAllNotifications();
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryColor, _primaryDarkColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
                ),
              ),
              // Правая часть - настройки по центру
              Expanded(
                child: Center(
                  child: IconButton(
                    icon: Icon(
                      LucideIcons.settings,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    final selectedDayProfiles = _getProfilesForDate(_selectedDay);
    
    return Column(
      children: [
        // Небольшой отступ сверху
        SafeArea(
          bottom: false,
          child: SizedBox(height: 8),
        ),
        // Календарь
        TableCalendar<Profile>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: (day) {
            return _getProfilesForDate(day);
          },
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: TextStyle(color: Colors.grey[600]),
            defaultTextStyle: TextStyle(color: Colors.grey[800]),
            selectedDecoration: BoxDecoration(
              color: _primaryColor,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: _primaryColor,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 3,
            markerSize: 6,
            canMarkersOverflow: true,
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            leftChevronIcon: Icon(LucideIcons.chevronLeft, color: Colors.grey[600]),
            rightChevronIcon: Icon(LucideIcons.chevronRight, color: Colors.grey[600]),
            titleTextStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            headerPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            headerMargin: EdgeInsets.zero,
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            weekendStyle: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          daysOfWeekHeight: 40,
          rowHeight: 52,
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
        ),
        const Divider(height: 1),
        // Список профилей с днем рождения в выбранный день
        Expanded(
          child: selectedDayProfiles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.cake,
                        size: 48,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Нет дней рождения',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'В этот день нет дней рождения',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: selectedDayProfiles.length,
                  itemBuilder: (context, index) {
                    final profile = selectedDayProfiles[index];
                    final age = getAge(profile.birthdate);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
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
                      child: GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                profileId: profile.id,
                              ),
                            ),
                          );
                          await _loadProfiles();
                          final notificationService = NotificationService();
                          await notificationService.scheduleAllNotifications();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              // Аватар
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(profile.avatarColor),
                                      _getDarkerShade(profile.avatarColor),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(profile.avatarColor).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    profile.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Информация
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2E2E2E),
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          LucideIcons.cake,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '$age ${_getAgeText(age)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _getAgeText(int age) {
    if (age % 10 == 1 && age % 100 != 11) {
      return 'год';
    }
    if (age % 10 >= 2 && age % 10 <= 4 && (age % 100 < 10 || age % 100 >= 20)) {
      return 'года';
    }
    return 'лет';
  }

  String _getDaysText(int days) {
    if (days % 10 == 1 && days % 100 != 11) {
      return 'день';
    }
    if (days % 10 >= 2 &&
        days % 10 <= 4 &&
        (days % 100 < 10 || days % 100 >= 20)) {
      return 'дня';
    }
    return 'дней';
  }
}

