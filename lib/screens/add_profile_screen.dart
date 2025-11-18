import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/profile.dart';
import '../models/group.dart';
import '../services/storage_service.dart';
import '../services/theme_service.dart';
import '../services/photo_service.dart';
import '../services/group_service.dart';
import '../widgets/group_selector.dart';
import '../theme/theme_helper.dart';
import '../localization/app_localizations.dart';

class AddProfileScreen extends StatefulWidget {
  final Profile? profile;

  const AddProfileScreen({super.key, this.profile});

  @override
  State<AddProfileScreen> createState() => _AddProfileScreenState();
}

class _AddProfileScreenState extends State<AddProfileScreen> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late final TextEditingController _dayController;
  late final TextEditingController _monthController;
  late final TextEditingController _yearController;
  late final TextEditingController _notesController;
  final StorageService _storageService = StorageService();
  final ThemeService _themeService = ThemeService();
  final PhotoService _photoService = PhotoService();
  final GroupService _groupService = GroupService();
  
  String? _photoPath;
  String? _oldPhotoPath; // Для удаления старого фото при замене
  bool _photoDeleted = false; // Флаг, что пользователь явно удалил фото
  int? _avatarColor; // Цвет аватара, задается один раз при создании
  String? _selectedGroupId; // Выбранная группа
  List<Group> _groups = [];

  bool get _isEditing => widget.profile != null;
  
  Color get _primaryColor => Color(_themeService.primaryColor);

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
    final profile = widget.profile;
    
    // Инициализируем уникальный ключ формы на основе ID профиля или времени создания
    _formKey = GlobalKey<FormState>(debugLabel: 'form_${profile?.id ?? DateTime.now().millisecondsSinceEpoch}');
    
    // Инициализируем контроллеры
    _nameController = TextEditingController(text: profile?.name ?? '');
    _notesController = TextEditingController(text: profile?.notes ?? '');
    
    // Инициализируем поля даты
    if (profile != null) {
      _dayController = TextEditingController(text: profile.birthdate.day.toString());
      _monthController = TextEditingController(text: profile.birthdate.month.toString());
      _yearController = TextEditingController(text: profile.birthdate.year.toString());
      // Проверяем существование файла перед установкой пути
      if (profile.photoPath != null && File(profile.photoPath!).existsSync()) {
        _photoPath = profile.photoPath;
        _oldPhotoPath = profile.photoPath;
      } else {
        // Если файл не существует, не устанавливаем путь
        _photoPath = null;
        _oldPhotoPath = null;
      }
      _avatarColor = profile.avatarColor;
      _selectedGroupId = profile.groupId;
    } else {
      _dayController = TextEditingController();
      _monthController = TextEditingController();
      _yearController = TextEditingController();
      // Генерируем цвет аватара один раз при создании нового профиля
      _avatarColor = StorageService.generatePastelColor();
    }
    
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final groups = await _groupService.getAllGroups();
    if (!mounted) return;
    setState(() {
      _groups = groups;
    });
  }

  Future<void> _showGroupSelector(BuildContext context) async {
    if (!mounted) return;
    
    final selectedId = await GroupSelector.show(
      context,
      selectedGroupId: _selectedGroupId,
      primaryColor: _primaryColor,
    );
    
    if (!mounted) return;
    
    if (selectedId != null || (selectedId == null && _selectedGroupId != null)) {
      setState(() {
        _selectedGroupId = selectedId;
      });
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
      // Удаляем старое фото, если оно было заменено
      if (_oldPhotoPath != null && _oldPhotoPath != _photoPath) {
        await _photoService.deletePhoto(_oldPhotoPath);
      }

      if (_isEditing && widget.profile != null) {
        // Редактирование существующего профиля
        // Определяем, какое фото сохранять:
        // 1. Если фото было явно удалено - сохраняем null
        // 2. Если выбрано новое фото - сохраняем новый путь
        // 3. Если фото не изменялось - сохраняем исходный путь из профиля
        String? photoPathToSave;
        if (_photoDeleted) {
          photoPathToSave = null;
        } else if (_photoPath != null) {
          // Новое фото было выбрано
          photoPathToSave = _photoPath;
        } else {
          // Фото не изменялось - сохраняем исходное из профиля
          photoPathToSave = widget.profile!.photoPath;
        }
        final updatedProfile = widget.profile!.copyWith(
          name: _nameController.text.trim(),
          birthdate: birthdate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          photoPath: photoPathToSave,
          groupId: _selectedGroupId,
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
          avatarColor: _avatarColor ?? StorageService.generatePastelColor(),
          photoPath: _photoPath,
          groupId: _selectedGroupId,
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

  Future<void> _deleteProfile() async {
    if (!_isEditing || widget.profile == null) return;

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
                  '${localizations.deleteProfileWithName} "${widget.profile!.name}"?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: context.textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  localizations.cannotRestore,
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

    if (confirmed == true && mounted) {
      try {
        await _storageService.deleteProfile(widget.profile!.id);
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка при удалении: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    if (!mounted) return;
    
    final localizations = AppLocalizations.of(context);
    final source = await showModalBottomSheet<ImageSource>(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(LucideIcons.image, size: 24, color: _primaryColor),
                title: Text(localizations.selectFromGallery),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: Icon(LucideIcons.camera, size: 24, color: _primaryColor),
                title: Text(localizations.takePhoto),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              if (_photoPath != null)
                ListTile(
                  leading: Icon(LucideIcons.trash, size: 24, color: Colors.red[400]),
                  title: Text(localizations.deletePhoto, style: TextStyle(color: Colors.red[400])),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      if (_oldPhotoPath == _photoPath) {
                        _oldPhotoPath = null;
                      }
                      _photoPath = null;
                      _photoDeleted = true; // Отмечаем, что фото было явно удалено
                    });
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    String? newPhotoPath;
    if (source == ImageSource.gallery) {
      newPhotoPath = await _photoService.pickImageFromGallery();
    } else if (source == ImageSource.camera) {
      newPhotoPath = await _photoService.pickImageFromCamera();
    }

    if (newPhotoPath != null && mounted) {
      setState(() {
        _photoPath = newPhotoPath;
        _photoDeleted = false; // Сбрасываем флаг, так как выбрано новое фото
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: IconButton(
                icon: Icon(LucideIcons.arrowLeft, size: 24, color: context.iconColor),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                mouseCursor: SystemMouseCursors.basic,
                tooltip: '',
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: IconButton(
                icon: Icon(LucideIcons.check, size: 24, color: _primaryColor),
                onPressed: _saveProfile,
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
        centerTitle: false,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Карточка с полями
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
                    // Аватар с фото
                    Center(
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(_avatarColor ?? StorageService.generatePastelColor()),
                                    _getDarkerShade(_avatarColor ?? StorageService.generatePastelColor()),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: _photoPath != null && File(_photoPath!).existsSync()
                                  ? ClipOval(
                                      child: Image.file(
                                        File(_photoPath!),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Center(
                                            child: Text(
                                              widget.profile?.name.isNotEmpty == true
                                                  ? widget.profile!.name[0].toUpperCase()
                                                  : (_nameController.text.isNotEmpty
                                                      ? _nameController.text[0].toUpperCase()
                                                      : ''),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 40,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        widget.profile?.name.isNotEmpty == true
                                            ? widget.profile!.name[0].toUpperCase()
                                            : (_nameController.text.isNotEmpty
                                                ? _nameController.text[0].toUpperCase()
                                                : ''),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: _primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _photoPath != null ? LucideIcons.pencil : LucideIcons.camera,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Поле имени
                    TextFormField(
                      controller: _nameController,
                      maxLength: 50,
                      onChanged: (value) {
                        setState(() {}); // Обновляем только текст инициала, цвет не меняется
                      },
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).name,
                        labelStyle: TextStyle(
                          color: context.secondaryTextColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        counterText: '', // Скрываем счетчик символов
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: context.textColor,
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
                              labelText: AppLocalizations.of(context).dayField,
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
                              labelText: AppLocalizations.of(context).monthField,
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
                              labelText: AppLocalizations.of(context).yearField,
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
                        labelText: AppLocalizations.of(context).notes,
                        labelStyle: TextStyle(
                          color: context.secondaryTextColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        counterText: '',
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: context.textColor,
                      ),
                      maxLines: 3,
                      maxLength: 500,
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '$currentLength / $maxLength',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.secondaryTextColor,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Выбор группы
                    GestureDetector(
                      onTap: () => _showGroupSelector(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context).group,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.secondaryTextColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedGroupId != null
                                        ? _groups.firstWhere(
                                            (g) => g.id == _selectedGroupId,
                                            orElse: () => Group(
                                              id: '',
                                              name: 'Неизвестная группа',
                                              createdAt: DateTime.now(),
                                            ),
                                          ).name
                                        : 'Без группы',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: context.textColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
            const SizedBox(height: 28),
            // Кнопка удаления (только при редактировании)
            if (_isEditing) ...[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.red,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _deleteProfile,
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
                    AppLocalizations.of(context).delete,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

