import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/profile.dart';
import '../services/storage_service.dart';
import '../services/theme_service.dart';
import '../utils/date_utils.dart';
import 'add_profile_screen.dart';

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

class ProfileScreen extends StatefulWidget {
  final String profileId;

  const ProfileScreen({super.key, required this.profileId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StorageService _storageService = StorageService();
  final ThemeService _themeService = ThemeService();
  Profile? _profile;
  bool _isLoading = true;
  bool _isAddingGift = false;
  final TextEditingController _newGiftController = TextEditingController();
  final Map<String, TextEditingController> _giftControllers = {};
  final Map<String, Timer> _saveTimers = {};
  
  Color get _primaryColor => Color(_themeService.primaryColor);
  Color get _primaryDarkColor => Color(_themeService.primaryDarkColor);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _newGiftController.dispose();
    for (var controller in _giftControllers.values) {
      controller.dispose();
    }
    for (var timer in _saveTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final profiles = await _storageService.loadProfiles();
    final profile = profiles.firstWhere(
      (p) => p.id == widget.profileId,
      orElse: () => throw Exception('Profile not found'),
    );

    setState(() {
      _profile = profile;
      _isLoading = false;
    });

    // Инициализируем контроллеры для существующих подарков
    for (var gift in profile.gifts) {
      if (!_giftControllers.containsKey(gift.id)) {
        _giftControllers[gift.id] = TextEditingController(text: gift.idea);
      }
    }
  }

  void _startAddingGift() {
    setState(() {
      _isAddingGift = true;
    });
  }

  Future<void> _saveNewGift() async {
    final text = _newGiftController.text.trim();
    if (text.isEmpty || _profile == null) return;

    final gift = Gift(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      profileId: _profile!.id,
      idea: text,
      createdAt: DateTime.now(),
    );

    await _storageService.addGift(_profile!.id, gift);
    _newGiftController.clear();
    await _loadProfile();
    setState(() {
      _isAddingGift = false;
    });
  }

  void _cancelAddingGift() {
    _newGiftController.clear();
    setState(() {
      _isAddingGift = false;
    });
  }

  void _onGiftTextChanged(String giftId, String text) {
    // Отменяем предыдущий таймер
    _saveTimers[giftId]?.cancel();

    // Создаем новый таймер для автосохранения через 1 секунду
    _saveTimers[giftId] = Timer(const Duration(seconds: 1), () {
      _saveGift(giftId);
    });
  }

  Future<void> _saveGift(String giftId) async {
    if (_profile == null || !_giftControllers.containsKey(giftId)) return;

    final text = _giftControllers[giftId]!.text;
    final trimmedText = text.trim();
    final gift = _profile!.gifts.firstWhere((g) => g.id == giftId);

    if (trimmedText.isEmpty) {
      // Если текст пустой - удаляем подарок
      await _storageService.deleteGift(_profile!.id, giftId);
      _giftControllers[giftId]?.dispose();
      _giftControllers.remove(giftId);
    } else if (trimmedText != gift.idea) {
      // Обновляем только если текст изменился
      final updatedGift = gift.copyWith(idea: trimmedText);
      await _storageService.updateGift(_profile!.id, updatedGift);
    }

    await _loadProfile();
  }

  Future<void> _deleteGift(String giftId) async {
    if (_profile == null) return;
    
      await _storageService.deleteGift(_profile!.id, giftId);
      _giftControllers[giftId]?.dispose();
      _giftControllers.remove(giftId);
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

    if (_profile == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Профиль не найден'),
          centerTitle: true,
          titleSpacing: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.grey),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              mouseCursor: SystemMouseCursors.basic,
              tooltip: '',
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
            icon: const Icon(Icons.arrow_back, color: Colors.grey),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ),
        actions: [
          // Кнопка редактирования
          GestureDetector(
            onTap: () async {
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
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(right: 12),
              child: Icon(
                LucideIcons.pencil,
                color: Colors.grey[600],
                size: 24,
              ),
            ),
          ),
          // Кнопка удаления
          GestureDetector(
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text('Удалить профиль'),
                  content: Text('Вы уверены, что хотите удалить ${profile.name}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom().copyWith(
                        splashFactory: NoSplash.splashFactory,
                      ),
                      child: Text(
                        'Отмена',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ).copyWith(
                        splashFactory: NoSplash.splashFactory,
                      ),
                      child: const Text('Удалить'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await _storageService.deleteProfile(profile.id);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(right: 20),
              child: Icon(
                LucideIcons.trash,
                color: Colors.grey[600],
                size: 24,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Карточка профиля
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
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
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                      child: Text(
                        profile.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                            fontSize: 36,
                          fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E2E2E),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.cake,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${formatDate(profile.birthdate)} • $age ${_getAgeText(age)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (profile.notes != null && profile.notes!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F4F2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                        profile.notes!,
                        style: TextStyle(
                            fontSize: 15,
                          color: Colors.grey[700],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Кнопка добавления или поле ввода
                    if (!_isAddingGift)
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_primaryColor, _primaryDarkColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: _primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                        onPressed: _startAddingGift,
                        icon: const Icon(LucideIcons.gift, size: 20),
                            label: const Text(
                              'Добавить идею',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 24,
                          ),
                              minimumSize: const Size(double.infinity, 0),
                          shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              splashFactory: NoSplash.splashFactory,
                            ),
                          ),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _newGiftController,
                            autofocus: true,
                            maxLines: null,
                            minLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Введите идею подарка...',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 15,
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF2E2E2E),
                            ),
                            onSubmitted: (_) => _saveNewGift(),
                            textInputAction: TextInputAction.done,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _cancelAddingGift,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(color: Colors.grey[300]!),
                                    splashFactory: NoSplash.splashFactory,
                                  ),
                                  child: Text(
                                    'Отмена',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [_primaryColor, _primaryDarkColor],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                child: ElevatedButton(
                                  onPressed: _saveNewGift,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      splashFactory: NoSplash.splashFactory,
                                  ),
                                    child: const Text(
                                      'Сохранить',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                    // Идеи подарков
                    if (futureGifts.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Text(
                        'Идеи подарков',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...futureGifts.map((gift) => _buildGiftItem(gift, true)),
                    ],

                    // Уже подаренные (группированные по годам)
                    if (pastGifts.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Text(
                        'Уже подарено',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                          letterSpacing: 0.3,
                        ),
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
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          // Подарки этого года
                          ...yearGifts.map((gift) => _buildGiftItem(gift, false)),
                        ];
                      }),
                    ],

                    if (profile.gifts.isEmpty && !_isAddingGift)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                LucideIcons.gift,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Пока нет идей подарков',
                            style: TextStyle(
                              color: Colors.grey[500],
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Добавьте первую!',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 13,
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

  String _getAgeText(int age) {
    if (age % 10 == 1 && age % 100 != 11) {
      return 'год';
    }
    if (age % 10 >= 2 && age % 10 <= 4 && (age % 100 < 10 || age % 100 >= 20)) {
      return 'года';
    }
    return 'лет';
  }

  Widget _buildGiftItem(Gift gift, bool isFuture) {
    // Создаем контроллер если его нет
    if (!_giftControllers.containsKey(gift.id)) {
      _giftControllers[gift.id] = TextEditingController(text: gift.idea);
    }

        return Dismissible(
          key: Key(gift.id),
          direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Удалить',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(LucideIcons.trash, color: Colors.white, size: 16),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        // Показываем подтверждение перед удалением
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Удалить подарок'),
            content: const Text('Вы уверены?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom().copyWith(
                  splashFactory: NoSplash.splashFactory,
                ),
                child: Text(
                  'Отмена',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ).copyWith(
                  splashFactory: NoSplash.splashFactory,
                ),
                child: const Text('Удалить'),
            ),
            ],
          ),
        );
        return confirmed ?? false;
      },
          onDismissed: (_) => _deleteGift(gift.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isFuture ? const Color(0xFFF5F4F2) : const Color(0xFFF0EFED),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: isFuture
                  ? TextField(
                      controller: _giftControllers[gift.id],
                      maxLines: null,
                      minLines: 1,
                      decoration: InputDecoration(
                        filled: false,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        hintText: 'Идея подарка...',
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
                onChanged: (text) => _onGiftTextChanged(gift.id, text),
                onSubmitted: (_) => _saveGift(gift.id),
                onEditingComplete: () => _saveGift(gift.id),
                      style: const TextStyle(
                        decoration: TextDecoration.none,
                        color: Color(0xFF2E2E2E),
                        fontSize: 15,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Text(
                        gift.idea,
                style: TextStyle(
                          decoration: TextDecoration.none,
                          color: Colors.grey[600],
                          fontSize: 15,
                        ),
                ),
              ),
            ),
            if (isFuture)
              GestureDetector(
                onTap: () => _toggleGiftStatus(gift.id),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    LucideIcons.check,
                    color: _primaryColor,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

