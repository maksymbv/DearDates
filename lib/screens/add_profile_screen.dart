import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/profile.dart';
import '../services/storage_service.dart';
import '../services/theme_service.dart';

class AddProfileScreen extends StatefulWidget {
  final Profile? profile;

  const AddProfileScreen({super.key, this.profile});

  @override
  State<AddProfileScreen> createState() => _AddProfileScreenState();
}

class _AddProfileScreenState extends State<AddProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dayController;
  late final TextEditingController _monthController;
  late final TextEditingController _yearController;
  late final TextEditingController _notesController;
  final StorageService _storageService = StorageService();
  final ThemeService _themeService = ThemeService();

  bool get _isEditing => widget.profile != null;
  
  Color get _primaryColor => Color(_themeService.primaryColor);
  Color get _primaryDarkColor => Color(_themeService.primaryDarkColor);

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
    final profile = widget.profile;
    
    // Инициализируем контроллеры
    _nameController = TextEditingController(text: profile?.name ?? '');
    _notesController = TextEditingController(text: profile?.notes ?? '');
    
    // Инициализируем поля даты
    if (profile != null) {
      _dayController = TextEditingController(text: profile.birthdate.day.toString());
      _monthController = TextEditingController(text: profile.birthdate.month.toString());
      _yearController = TextEditingController(text: profile.birthdate.year.toString());
    } else {
      _dayController = TextEditingController();
      _monthController = TextEditingController();
      _yearController = TextEditingController();
    }
  }

  DateTime? _parseDate() {
    try {
      final day = int.tryParse(_dayController.text.trim());
      final month = int.tryParse(_monthController.text.trim());
      final year = int.tryParse(_yearController.text.trim());

      if (day == null || month == null || year == null) {
        return null;
      }

      // Валидация диапазонов
      final currentYear = DateTime.now().year;
      if (day < 1 || day > 31) return null;
      if (month < 1 || month > 12) return null;
      if (year < 1900 || year > currentYear) return null;

      final date = DateTime(year, month, day);
      
      // Проверка, что дата не в будущем
      if (date.isAfter(DateTime.now())) {
        return null;
      }

      // Проверка, что дата валидна (например, 31 февраля не существует)
      if (date.year != year || date.month != month || date.day != day) {
        return null;
      }

      return date;
    } catch (e) {
      return null;
    }
  }

  String? _validateDate() {
    final day = _dayController.text.trim();
    final month = _monthController.text.trim();
    final year = _yearController.text.trim();

    if (day.isEmpty || month.isEmpty || year.isEmpty) {
      return 'Заполните все поля даты';
    }

    final dayNum = int.tryParse(day);
    final monthNum = int.tryParse(month);
    final yearNum = int.tryParse(year);
    final currentYear = DateTime.now().year;

    if (dayNum == null || monthNum == null || yearNum == null) {
      return 'Введите корректные числа';
    }

    if (dayNum < 1 || dayNum > 31) {
      return 'День должен быть от 1 до 31';
    }

    if (monthNum < 1 || monthNum > 12) {
      return 'Месяц должен быть от 1 до 12';
    }

    if (yearNum < 1900 || yearNum > currentYear) {
      return 'Год должен быть от 1900 до $currentYear';
    }

    final date = _parseDate();
    if (date == null) {
      return 'Неверная дата (проверьте, что дата существует)';
    }

    if (date.isAfter(DateTime.now())) {
      return 'Дата не может быть в будущем';
    }

    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final dateError = _validateDate();
    if (dateError != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(dateError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final birthdate = _parseDate();
    if (birthdate == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Неверная дата рождения'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (!mounted) return;
    final navigator = Navigator.of(context);
    
    try {
      if (_isEditing && widget.profile != null) {
        // Редактирование существующего профиля
        final updatedProfile = widget.profile!.copyWith(
          name: _nameController.text.trim(),
          birthdate: birthdate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
        await _storageService.updateProfile(updatedProfile);
      } else {
        // Создание нового профиля
        final profile = Profile(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          birthdate: birthdate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          createdAt: DateTime.now(),
          avatarColor: StorageService.generatePastelColor(),
        );
        await _storageService.addProfile(profile);
      }
      
      if (mounted) {
        navigator.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при сохранении: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    _nameController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактировать профиль' : 'Добавить профиль'),
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Карточка с полями
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
                    // Поле имени
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Имя',
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2E2E2E),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Введите имя';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    // Заголовок даты рождения
                    Text(
                      'Дата рождения',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Поля даты
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _dayController,
                            decoration: InputDecoration(
                              labelText: 'День',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2E2E2E),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  final day = int.tryParse(value);
                                  if (day != null && day > 31) {
                                    _dayController.value = TextEditingValue(
                                      text: '31',
                                      selection: const TextSelection.collapsed(offset: 2),
                                    );
                                  }
                                }
                                if (value.length == 2 && _monthController.text.isEmpty) {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return null;
                                }
                                final day = int.tryParse(value.trim());
                                if (day == null || day < 1 || day > 31) {
                                  return '1-31';
                                }
                                return null;
                              },
                            ),
                          ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _monthController,
                            decoration: InputDecoration(
                              labelText: 'Месяц',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2E2E2E),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  final month = int.tryParse(value);
                                  if (month != null && month > 12) {
                                    _monthController.value = TextEditingValue(
                                      text: '12',
                                      selection: const TextSelection.collapsed(offset: 2),
                                    );
                                  }
                                }
                                if (value.length == 2 && _yearController.text.isEmpty) {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return null;
                                }
                                final month = int.tryParse(value.trim());
                                if (month == null || month < 1 || month > 12) {
                                  return '1-12';
                                }
                                return null;
                              },
                            ),
                          ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _yearController,
                            decoration: InputDecoration(
                              labelText: 'Год',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2E2E2E),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  final year = int.tryParse(value);
                                  final currentYear = DateTime.now().year;
                                  if (year != null && year > currentYear) {
                                    _yearController.value = TextEditingValue(
                                      text: currentYear.toString(),
                                      selection: TextSelection.collapsed(offset: currentYear.toString().length),
                                    );
                                  }
                                }
                              },
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return null;
                                }
                                final year = int.tryParse(value.trim());
                                final currentYear = DateTime.now().year;
                                if (year == null || year < 1900 || year > currentYear) {
                                  return '1900-$currentYear';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final dateError = _validateDate();
                        if (dateError != null && 
                            _dayController.text.isNotEmpty &&
                            _monthController.text.isNotEmpty &&
                            _yearController.text.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 4, top: 4),
                            child: Text(
                              dateError,
                              style: TextStyle(
                                color: Colors.red[400],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 24),
                    // Поле заметок
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: 'Заметки',
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2E2E2E),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Кнопка сохранения
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [_primaryColor, _primaryDarkColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ).copyWith(
                  splashFactory: NoSplash.splashFactory,
                ),
                child: Text(
                  _isEditing ? 'Сохранить изменения' : 'Сохранить',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

