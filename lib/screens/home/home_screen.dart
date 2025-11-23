import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/profile.dart';
import '../../models/group.dart';
import '../../services/storage_service.dart';
import '../../services/notification_service.dart';
import '../../services/group_service.dart';
import '../../utils/date_utils.dart';
import '../../widgets/profile_list.dart';
import '../../widgets/group_menu_dialog.dart';
import '../../widgets/create_group_dialog.dart';
import '../../widgets/edit_group_dialog.dart';
import '../../themes/app_text_styles.dart';
import '../../themes/theme_helper.dart';
import '../../l10n/app_localizations.dart';
import '../profile/add_profile_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  final GroupService _groupService = GroupService();
  List<Profile> _profiles = [];
  List<Profile> _filteredProfiles = [];
  List<Group> _groups = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchDebounce;
  bool _isSearching = false;
  String? _selectedGroupId; // null означает "Все"
  
  @override
  void initState() {
    super.initState();
    _initializeAndLoad();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
  
  Color _getPrimaryColor(BuildContext context) => Theme.of(context).colorScheme.primary;

  Future<void> _initializeAndLoad() async {
    // Инициализируем уведомления и планируем их
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();
      // Не блокируем инициализацию UI планированием уведомлений — планируем после первого кадра
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // scheduleAllNotifications может выполняться асинхронно, не ждем его здесь
        notificationService.scheduleAllNotifications();
      });
    } catch (e) {
      // Игнорируем ошибки инициализации уведомлений
      debugPrint('Failed to initialize notifications: $e');
    }
    
    // Загружаем профили
    await _loadProfiles();
  }

  // Сортировка по количеству дней до дня рождения
  void _sortProfiles(List<Profile> profiles) {
    profiles.sort((a, b) {
      final daysA = daysUntilBirthday(a.birthdate);
      final daysB = daysUntilBirthday(b.birthdate);
      return daysA.compareTo(daysB);
    });
  }

  Future<void> _loadProfiles() async {
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);
      final profiles = await _storageService.loadProfiles();
      final groups = await _groupService.getAllGroups();
      
      if (!mounted) return;
      
      // Применяем сортировку по дням до дня рождения
      _sortProfiles(profiles);

      setState(() {
        _profiles = profiles;
        _groups = groups;
        _isLoading = false;
      });
      
      // Применяем фильтрацию
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading profiles: $e');
      if (!mounted) return;
      setState(() {
        _profiles = [];
        _filteredProfiles = [];
        _isLoading = false;
      });
    }
  }

  // Получить название группы по ID
  String _getGroupName(String? groupId) {
    if (groupId == null) return 'All';
    try {
      return _groups.firstWhere((g) => g.id == groupId).name;
    } catch (e) {
      // Если группа не найдена (например, была удалена), возвращаем "All"
      // чтобы бейдж не отображался
      return 'All';
    }
  }


  // Проверяет, начинается ли какое-либо слово в тексте с запроса
  bool _startsWithWord(String text, String query) {
    final lowerText = text.toLowerCase();
    final words = lowerText.split(RegExp(r'\s+'));
    return words.any((word) => word.startsWith(query));
  }

  // Применяет все фильтры (по группе и поиску)
  void _applyFilters() {
    if (!mounted) return;
    
    final query = _isSearching && _searchController.text.isNotEmpty
        ? _searchController.text.toLowerCase().trim()
        : null;
    
    setState(() {
      _filteredProfiles = _profiles
          .where((profile) =>
              _selectedGroupId == null || profile.groupId == _selectedGroupId)
          .where((profile) {
            if (query == null) return true;
            
            final nameMatch = _startsWithWord(profile.name, query);
            final notesMatch = profile.notes != null 
                ? _startsWithWord(profile.notes!, query)
                : false;
            final giftsMatch = profile.gifts.any(
                (gift) => _startsWithWord(gift.idea, query));
            
            return nameMatch || notesMatch || giftsMatch;
          })
          .toList();
      
      _sortProfiles(_filteredProfiles);
    });
  }

  void _filterProfiles(String query) {
    // deprecated path - keep for compatibility
    _applyFilters();
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    // Debounce filtering to avoid heavy work on every keystroke
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      _applyFilters();
    });
  }

  // Выбор группы для фильтрации
  void _selectGroup(String? groupId) {
    if (!mounted) return;
    setState(() {
      _selectedGroupId = groupId;
    });
    _applyFilters();
  }

  // Показать диалог редактирования группы при долгом нажатии
  Future<void> _showGroupMenu(BuildContext context, Group group) async {
    if (!context.mounted) return;
    
    // Сразу открываем диалог редактирования
    await _showEditGroupDialog(context, group);
  }

  // Диалог создания группы
  Future<void> _showCreateGroupDialog(BuildContext context) async {
    if (!mounted || !context.mounted) return;
    
    final result = await CreateGroupDialog.show(context, _getPrimaryColor(context));
    
    if (!mounted) return;
    
    if (result != null && result.isNotEmpty) {
      await _groupService.createGroup(result);
      await _loadProfiles();
    }
  }

  // Диалог редактирования группы
  Future<void> _showEditGroupDialog(BuildContext context, Group group) async {
    if (!mounted || !context.mounted) return;
    
    final result = await EditGroupDialog.show(context, group, _getPrimaryColor(context));
    
    if (!mounted) return;
    
    // Небольшая задержка перед обновлением данных
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (!mounted) return;
    
    if (result != null) {
      if (result.shouldDelete) {
        // Пользователь хочет удалить группу
        await _deleteGroup(context, group);
      } else if (result.newName != null && result.newName!.isNotEmpty && result.newName != group.name) {
        // Пользователь изменил название группы
        await _groupService.updateGroup(group.copyWith(name: result.newName!));
        await _loadProfiles();
      }
    }
  }

  // Удаление группы
  Future<void> _deleteGroup(BuildContext context, Group group) async {
    if (!mounted) return;
    
    final localizations = AppLocalizations.of(context);
    final profiles = await _storageService.loadProfiles();
    if (!mounted) return;
    
    final profilesInGroup = profiles.where((p) => p.groupId == group.id).toList();

    if (profilesInGroup.isNotEmpty) {
      if (!mounted) return;
      
      final count = profilesInGroup.length;
      final profileText = count % 10 == 1 && count % 100 != 11
          ? localizations.profileSingular
          : ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100))
              ? localizations.profilePlural2
              : localizations.profilePlural;
      
      final message = localizations.deleteGroupMessage
          .replaceAll('{groupName}', group.name)
          .replaceAll('{count}', count.toString())
          .replaceAll('{profileText}', profileText);
      
      if (!context.mounted) return;
      final confirmed = await showModalBottomSheet<bool>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.delete,
                    style: AppTextStyles.heading2(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: AppTextStyles.body(context),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ).copyWith(
                            splashFactory: NoSplash.splashFactory,
                          ),
                          child: Text(
                            localizations.cancel,
                            style: AppTextStyles.button(context).copyWith(
                              color: context.secondaryTextColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ).copyWith(
                            splashFactory: NoSplash.splashFactory,
                          ),
                          child: Text(
                            localizations.delete,
                            style: AppTextStyles.button(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      );

      if (!mounted) return;
      if (confirmed != true) return;

      // Перемещаем профили в "All"
      for (final profile in profilesInGroup) {
        await _storageService.updateProfile(profile.copyWith(groupId: null));
        if (!mounted) return;
      }
    }

    if (!mounted) return;
    
    // Удаляем группу
    await _groupService.deleteGroup(group.id);
    
    if (!mounted) return;
    
    // Перезагружаем данные (профили и группы)
    await _loadProfiles();
    
    if (!mounted) return;
    
    // Если удаленная группа была выбрана, сбрасываем выбор
    if (_selectedGroupId == group.id) {
      _selectGroup(null);
    }
  }


  void _startSearch() {
    if (!mounted) return;
    setState(() {
      _isSearching = true;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _stopSearch() {
    if (!mounted) return;
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
    _searchDebounce?.cancel();
    _applyFilters();
    _searchFocusNode.unfocus();
  }

  // Виджет кнопки фильтра группы
  Widget _buildGroupFilterButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    int? count,
    VoidCallback? onLongPress,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _getPrimaryColor(context) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.body(context).copyWith(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : context.textColor,
              ),
            ),
            if (count != null && count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : context.secondaryTextColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: AppTextStyles.caption(context).copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : context.secondaryTextColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  autofocus: true,
                  style: AppTextStyles.heading2(context).copyWith(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).searchHint,
                    hintStyle: AppTextStyles.heading2(context).copyWith(
                      fontSize: 18,
                      color: context.secondaryTextColor,
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
                  onChanged: _onSearchChanged,
                  onSubmitted: (_) {
                    _searchFocusNode.unfocus();
                  },
                ),
              )
            : null,
        centerTitle: false,
        titleSpacing: 0,
        leading: _isSearching
            ? Padding(
                padding: const EdgeInsets.only(left: 20),
                child: IconButton(
                  icon: Icon(LucideIcons.arrowLeft, size: 24, color: context.iconColor),
                  onPressed: _stopSearch,
                  padding: EdgeInsets.zero,
                  mouseCursor: SystemMouseCursors.basic,
                  tooltip: '',
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(left: 20),
                child: IconButton(
                  icon: Icon(LucideIcons.search, size: 24, color: context.iconColor),
                  onPressed: _startSearch,
                  padding: EdgeInsets.zero,
                  mouseCursor: SystemMouseCursors.basic,
                  tooltip: '',
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                ),
              ),
        actions: [
          if (_isSearching)
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, child) {
                if (value.text.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      icon: Icon(LucideIcons.x, size: 24, color: context.iconColor),
                      onPressed: () {
                        _searchController.clear();
                        _searchDebounce?.cancel();
                        _applyFilters();
                      },
                      padding: EdgeInsets.zero,
                      mouseCursor: SystemMouseCursors.basic,
                      tooltip: '',
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: Icon(LucideIcons.settings, size: 24, color: context.iconColor),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              padding: EdgeInsets.zero,
              mouseCursor: SystemMouseCursors.basic,
              tooltip: '',
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Фильтр по группам
          if (!_isLoading && _profiles.isNotEmpty)
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                children: [
                  // Кнопка создания новой группы
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Material(
                      color: Theme.of(context).cardColor,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () => _showCreateGroupDialog(context),
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          child: Icon(
                            LucideIcons.plus,
                            size: 18,
                            color: context.iconColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Кнопка "Все"
                  _buildGroupFilterButton(
                    label: AppLocalizations.of(context).all,
                    isSelected: _selectedGroupId == null,
                    count: _selectedGroupId == null ? _profiles.length : null,
                    onTap: () => _selectGroup(null),
                  ),
                  const SizedBox(width: 8),
                  // Кнопки для каждой группы
                  ..._groups.map((group) {
                    // Подсчитываем количество профилей в группе
                    final count = _profiles.where((p) => p.groupId == group.id).length;
                    final isSelected = _selectedGroupId == group.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildGroupFilterButton(
                        label: group.name,
                        isSelected: isSelected,
                        count: isSelected ? count : null, // Показываем количество только для активной группы
                        onTap: () => _selectGroup(group.id),
                        onLongPress: () => _showGroupMenu(context, group),
                      ),
                    );
                  }),
                ],
              ),
            ),
          // Основной контент
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: _getPrimaryColor(context).withOpacity(0.7),
                    ),
                  )
                : _profiles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: Icon(
                          LucideIcons.cake,
                          size: 64,
                          color: _getPrimaryColor(context).withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppLocalizations.of(context).noProfilesYet,
                        style: AppTextStyles.heading2(context).copyWith(
                          fontSize: 20,
                          color: context.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context).addFirstProfile,
                        style: AppTextStyles.caption(context).copyWith(
                          fontSize: 15,
                          color: context.secondaryTextColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
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
                              color: Theme.of(context).cardColor,
                              border: Border(
                                bottom: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  LucideIcons.search,
                                  size: 16,
                                  color: context.textColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _filteredProfiles.isEmpty
                                      ? AppLocalizations.of(context).nothingFound
                                      : '${AppLocalizations.of(context).found}: ${_filteredProfiles.length}',
                                  style: AppTextStyles.caption(context).copyWith(
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
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    LucideIcons.x,
                                    size: 64,
                                    color: context.secondaryTextColor.withOpacity(0.4),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    AppLocalizations.of(context).nothingFound,
                                    style: AppTextStyles.heading2(context).copyWith(
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppLocalizations.of(context).tryDifferentQuery,
                                    style: AppTextStyles.caption(context).copyWith(
                                      fontSize: 14,
                                      color: context.secondaryTextColor.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return ProfileList(
                            profiles: _filteredProfiles,
                            groups: _groups,
                            primaryColor: _getPrimaryColor(context),
                            getGroupName: _getGroupName,
                            onRefresh: _loadProfiles,
                            onProfileUpdated: _loadProfiles,
                          );
                        },
                      ),
                    ),
                  ],
                ),
          ),
        ],
      ),
      floatingActionButton: Material(
        color: _getPrimaryColor(context),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddProfileScreen(),
              ),
            );
            if (!mounted) return;
            await _loadProfiles();
            if (!mounted) return;
            // Уведомления автоматически обновляются в StorageService.addProfile()
          },
          customBorder: const CircleBorder(),
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            child: Icon(LucideIcons.plus, color: Colors.white, size: 24),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

