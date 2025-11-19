import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/profile.dart';
import '../models/group.dart';
import '../services/storage_service.dart';
import '../services/theme_service.dart';
import '../services/group_service.dart';
import '../utils/date_utils.dart';
import '../widgets/group_badge.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_helper.dart';
import '../localization/app_localizations.dart';
import 'add_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String profileId;

  const ProfileScreen({super.key, required this.profileId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StorageService _storageService = StorageService();
  final ThemeService _themeService = ThemeService();
  final GroupService _groupService = GroupService();
  Profile? _profile;
  List<Group> _groups = [];
  bool _isLoading = true;
  final TextEditingController _giftInputController = TextEditingController();
  String? _editingGiftId; // ID редактируемой идеи (null = новая идея)
  
  Color get _primaryColor => Color(_themeService.primaryColor);

  @override
  void initState() {
    super.initState();
    _loadProfile();
    // Слушаем изменения в поле ввода для активации кнопки
    _giftInputController.addListener(() {
      setState(() {}); // Обновляем UI для изменения цвета кнопки
    });
  }

  @override
  void dispose() {
    _giftInputController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final profiles = await _storageService.loadProfiles();
    
    if (!mounted) return;
    
    final profile = profiles.firstWhere(
      (p) => p.id == widget.profileId,
      orElse: () => Profile(
        id: '',
        name: '',
        birthdate: DateTime.now(),
        createdAt: DateTime.now(),
        avatarColor: 0xFFD68A9E,
      ),
    );
    
    // Если профиль не найден (был удален), закрываем экран
    if (profile.id.isEmpty) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }
    
    final groups = await _groupService.getAllGroups();

    if (!mounted) return;
    setState(() {
      _profile = profile;
      _groups = groups;
      _isLoading = false;
    });
  }


  void _startEditingGift(String? giftId) {
    if (_profile == null) return;
    
    if (giftId == null) {
      // Начинаем добавление новой идеи
      setState(() {
        _editingGiftId = null;
        _giftInputController.clear();
      });
    } else {
      // Начинаем редактирование существующей идеи (только для будущих подарков)
      final gift = _profile!.gifts.firstWhere((g) => g.id == giftId);
      // Проверяем, что подарок еще не подарен
      if (gift.isGiven) return;
      
      setState(() {
        _editingGiftId = giftId;
        _giftInputController.text = gift.idea;
      });
    }
  }

  void _cancelEditing() {
    setState(() {
      _editingGiftId = null;
      _giftInputController.clear();
    });
  }

  Future<void> _saveGiftFromInput() async {
    if (_profile == null) return;

    final text = _giftInputController.text.trim();

    // Если текст пустой - отменяем редактирование
    if (text.isEmpty) {
      _cancelEditing();
      return;
    }

    if (_editingGiftId == null) {
      // Создаем новую идею
      final gift = Gift(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        profileId: _profile!.id,
        idea: text,
        createdAt: DateTime.now(),
      );
      await _storageService.addGift(_profile!.id, gift);
    } else {
      // Обновляем существующую идею
      await _saveGift(_editingGiftId!, text);
    }

    // Очищаем поле и перезагружаем профиль
    _giftInputController.clear();
    await _loadProfile();

    if (!mounted) return;
    setState(() {
      _editingGiftId = null;
    });
  }

  Future<void> _saveGift(String giftId, String newText) async {
    if (_profile == null) return;

    final trimmed = newText.trim();
    final gift = _profile!.gifts.firstWhere((g) => g.id == giftId);

    if (trimmed.isEmpty) {
      // Если текст пустой - удаляем подарок
      await _storageService.deleteGift(_profile!.id, giftId);
      await _loadProfile();
    } else if (gift.idea != trimmed) {
      // Обновляем только если текст изменился
      final updatedGift = gift.copyWith(idea: trimmed);
      await _storageService.updateGift(_profile!.id, updatedGift);
      await _loadProfile();
    }
  }

  Future<void> _deleteGift(String giftId) async {
    if (_profile == null) return;
    
    await _storageService.deleteGift(_profile!.id, giftId);
    await _loadProfile();
  }

  Future<void> _toggleGiftStatus(String giftId) async {
    if (_profile == null) return;

    final gift = _profile!.gifts.firstWhere((g) => g.id == giftId);
    final isNowGiven = !gift.isGiven;
    final currentYear = DateTime.now().year;
    
    final updatedGift = gift.copyWith(
      isGiven: isNowGiven,
      givenYear: isNowGiven ? currentYear : null, // Записываем текущий год при отметке как подаренного
    );
    await _storageService.updateGift(_profile!.id, updatedGift);
    await _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: _primaryColor.withOpacity(0.7),
          ),
        ),
      );
    }
    
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {

    if (_profile == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Профиль не найден'),
          centerTitle: true,
          titleSpacing: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 20),
              child: IconButton(
              icon: Icon(LucideIcons.arrowLeft, color: context.iconColor, size: 24),
              onPressed: () {
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              padding: EdgeInsets.zero,
              mouseCursor: SystemMouseCursors.basic,
              tooltip: '',
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
          ),
        ),
        body: const Center(child: Text('Профиль не найден')),
      );
    }

    final profile = _profile!;
    final age = getAge(profile.birthdate);
    final futureGifts = profile.gifts.where((g) => !g.isGiven).toList();
    final pastGifts = profile.gifts.where((g) => g.isGiven).toList();
    
    // Группируем подаренные подарки по годам
    final Map<int, List<Gift>> giftsByYear = {};
    for (var gift in pastGifts) {
      final year = gift.givenYear ?? DateTime.now().year; // Если год не указан, используем текущий
      if (!giftsByYear.containsKey(year)) {
        giftsByYear[year] = [];
      }
      giftsByYear[year]!.add(gift);
    }
    
    // Сортируем годы по убыванию (новые годы сверху)
    final sortedYears = giftsByYear.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: true,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: context.iconColor, size: 24),
            onPressed: () {
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            padding: EdgeInsets.zero,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
        ),
        actions: [
          // Кнопка редактирования
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: Icon(LucideIcons.pencil, size: 24, color: context.iconColor),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProfileScreen(profile: profile),
                  ),
                );
                if (result == true) {
                  await _loadProfile();
                }
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
      bottomNavigationBar: null,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Карточка профиля
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: context.cardShadows,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Фото слева, информация справа
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Фото
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(profile.avatarColor),
                                context.getDarkerShade(profile.avatarColor),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(profile.avatarColor).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: profile.photoPath != null && File(profile.photoPath!).existsSync()
                              ? ClipOval(
                                  child: Image.file(
                                    File(profile.photoPath!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Text(
                                          profile.name[0].toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    profile.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 16),
                        // Информация справа
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Имя с бейджиком группы
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      profile.name,
                                      style: AppTextStyles.heading1(context),
                                    ),
                                  ),
                                  if (profile.groupId != null) ...[
                                    const SizedBox(width: 8),
                                    Builder(
                                      builder: (context) {
                                        try {
                                          final groupId = profile.groupId;
                                          if (groupId != null) {
                                            final group = _groups.firstWhere((g) => g.id == groupId);
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: GroupBadge(
                                                groupName: group.name,
                                                primaryColor: _primaryColor,
                                              ),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        } catch (e) {
                                          return const SizedBox.shrink();
                                        }
                                      },
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Дата рождения
                              Row(
                                children: [
                                  Icon(
                                    LucideIcons.cake,
                                    size: 16,
                                    color: context.iconColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    formatDateFull(profile.birthdate),
                                    style: AppTextStyles.secondary(context).copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Возраст
                              Text(
                                '$age ${_getAgeText(age, AppLocalizations.of(context))}',
                                style: AppTextStyles.secondary(context).copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Заметки снизу
                    if (profile.notes != null && profile.notes!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.isDarkMode
                              ? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5)
                              : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      child: Text(
                        profile.notes!,
                        style: AppTextStyles.body(context).copyWith(
                          color: context.secondaryTextColor,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Карточка подарков
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: context.cardShadows,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Поле ввода с кнопкой подарка (всегда видно)
                    _buildGiftInputField(),

                    // Идеи подарков
                    if (futureGifts.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Text(
                        AppLocalizations.of(context).giftIdeas,
                        style: AppTextStyles.heading2(context),
                      ),
                      const SizedBox(height: 16),
                      ...futureGifts.map((gift) => _buildGiftCard(gift, true)),
                    ],

                    // Уже подаренные (группированные по годам)
                    if (pastGifts.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Text(
                        AppLocalizations.of(context).alreadyGiven,
                        style: AppTextStyles.heading2(context),
                      ),
                      const SizedBox(height: 16),
                      // Отображаем подарки по годам
                      ...sortedYears.expand((year) {
                        final yearGifts = giftsByYear[year]!;
                        return [
                          // Заголовок года
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: 12,
                              top: year == sortedYears.first ? 0 : 20,
                            ),
                            child: Text(
                              year.toString(),
                              style: AppTextStyles.secondary(context).copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          // Подарки этого года
                          ...yearGifts.map((gift) => _buildGiftCard(gift, false)),
                        ];
                      }),
                    ],

                    if (profile.gifts.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                LucideIcons.gift,
                                size: 48,
                                color: context.secondaryTextColor,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                AppLocalizations.of(context).noGiftsYet,
                                style: AppTextStyles.body(context).copyWith(
                                  color: context.secondaryTextColor.withOpacity(0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppLocalizations.of(context).addFirst,
                                style: AppTextStyles.caption(context).copyWith(
                                  color: context.secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAgeText(int age, AppLocalizations localizations) {
    if (age % 10 == 1 && age % 100 != 11) {
      return localizations.year;
    }
    if (age % 10 >= 2 && age % 10 <= 4 && (age % 100 < 10 || age % 100 >= 20)) {
      return localizations.years;
    }
    return localizations.yearsOld;
  }

  Widget _buildGiftInputField() {
    final isEditing = _editingGiftId != null;
    
    return Container(
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5)
            : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 48, // Минимальная высота как у карточек
                maxHeight: 300, // Максимальная высота
              ),
              child: TextField(
                controller: _giftInputController,
                maxLines: null,
                minLines: 1,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.2, // Высота строки для выравнивания с карточками
                ),
                decoration: InputDecoration(
                  filled: false,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  hintText: isEditing 
                      ? 'Edit gift idea...'
                      : 'Add gift idea...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
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
                ),
                textInputAction: TextInputAction.newline,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: IconButton(
              icon: Icon(
                LucideIcons.gift,
                size: 24,
                color: _giftInputController.text.trim().isNotEmpty 
                    ? _primaryColor 
                    : context.iconColor.withOpacity(0.5),
              ),
              onPressed: _saveGiftFromInput,
              padding: EdgeInsets.only(right: 10),
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftCard(Gift gift, bool isFuture) {
    final isEditing = _editingGiftId == gift.id;
    
    return Dismissible(
      key: Key(gift.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          AppLocalizations.of(context).delete,
          style: AppTextStyles.button(context).copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      confirmDismiss: (_) async {
        if (!context.mounted) return false;
        final localizations = AppLocalizations.of(context);
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
                      localizations.deleteGiftConfirm,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: context.textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      localizations.areYouSure,
                      style: TextStyle(
                        fontSize: 16,
                        color: context.secondaryTextColor,
                      ),
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: context.textColor,
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
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
        return confirmed ?? false;
      },
      onDismissed: (_) => _deleteGift(gift.id),
      child: GestureDetector(
        onTap: isFuture ? () => _startEditingGift(gift.id) : null,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isEditing
                ? _primaryColor.withOpacity(0.1)
                : (isFuture 
                    ? (context.isDarkMode
                        ? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5)
                        : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.6))
                    : (context.isDarkMode
                        ? Theme.of(context).colorScheme.surfaceContainerHigh.withOpacity(0.4)
                        : Theme.of(context).colorScheme.surfaceContainerHigh.withOpacity(0.5))),
            borderRadius: BorderRadius.circular(16),
            border: isEditing 
                ? Border.all(color: _primaryColor, width: 2)
                : null,
          ),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 48, // Минимальная высота как у TextField
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    gift.idea,
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      color: isEditing ? _primaryColor : context.textColor,
                      fontSize: 15,
                      fontWeight: isEditing ? FontWeight.w600 : FontWeight.normal,
                      height: 1.2, // Высота строки для выравнивания
                    ),
                  ),
                ),
                if (isFuture && !isEditing)
                  GestureDetector(
                    onTap: () => _toggleGiftStatus(gift.id),
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: Icon(
                        LucideIcons.check,
                        color: _primaryColor,
                        size: 24,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

