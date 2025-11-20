import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/profile.dart';
import '../models/group.dart';
import '../services/storage_service.dart';
import '../services/theme_service.dart';
import '../services/photo_service.dart';
import '../services/group_service.dart';
import '../widgets/group_selector.dart';
import '../widgets/custom_date_picker.dart';
import '../theme/theme_helper.dart';
import '../localization/app_localizations.dart';
import '../utils/date_utils.dart';

class AddProfileScreen extends StatefulWidget {
  final Profile? profile;

  const AddProfileScreen({super.key, this.profile});

  @override
  State<AddProfileScreen> createState() => _AddProfileScreenState();
}

class _AddProfileScreenState extends State<AddProfileScreen> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  DateTime? _selectedDate;
  final StorageService _storageService = StorageService();
  final ThemeService _themeService = ThemeService();
  final PhotoService _photoService = PhotoService();
  final GroupService _groupService = GroupService();
  
  String? _photoPath;
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
    
    // Инициализируем дату
    if (profile != null) {
      _selectedDate = profile.birthdate;
      // Проверяем существование файла перед установкой пути
      if (profile.photoPath != null && File(profile.photoPath!).existsSync()) {
        _photoPath = profile.photoPath;
      } else {
        // Если файл не существует, не устанавливаем путь
        _photoPath = null;
      }
      _avatarColor = profile.avatarColor;
      _selectedGroupId = profile.groupId;
    } else {
      _selectedDate = null;
      // Генерируем цвет аватара один раз при создании нового профиля
      _avatarColor = StorageService.generatePastelColor();
    }
    
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final groups = await _groupService.getAllGroups();
    safeSetState(() {
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
      safeSetState(() {
        _selectedGroupId = selectedId;
      });
    }
  }

  String? _validateDate() {
    final localizations = AppLocalizations.of(context);
    if (_selectedDate == null) {
      return localizations.pleaseSelectBirthdate;
    }

    final date = _selectedDate!;

    // Проверка, что дата не в будущем
    final now = DateTime.now();
    if (date.isAfter(DateTime(now.year, now.month, now.day))) {
      return localizations.dateCannotBeFuture;
    }

    return null;
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!context.mounted) return;
    
    final DateTime now = DateTime.now();
    final DateTime firstDate = DateTime(1, 1, 1);
    final DateTime lastDate = DateTime(now.year, now.month, now.day);
    final DateTime initialDate = _selectedDate ?? DateTime(now.year - 20, 1, 1);

    final picked = await CustomDatePicker.show(
      context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != _selectedDate) {
      safeSetState(() {
        _selectedDate = picked;
      });
    }
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

    if (_selectedDate == null) {
      if (!mounted) return;
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.pleaseSelectBirthdate),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final birthdate = _selectedDate!;
    
    if (!mounted) return;
    final navigator = Navigator.of(context);
    
    try {
      // Удаляем старое фото, если оно было заменено новым
      if (_isEditing && widget.profile != null && widget.profile!.photoPath != null) {
        // Если было выбрано новое фото, удаляем старое
        if (_photoPath != null && _photoPath != widget.profile!.photoPath) {
          await _photoService.deletePhoto(widget.profile!.photoPath!);
        }
        // Если фото было удалено, удаляем старое
        if (_photoDeleted && widget.profile!.photoPath != null) {
          await _photoService.deletePhoto(widget.profile!.photoPath!);
        }
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
        if (!mounted) return;
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
        if (!mounted) return;
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
      
      if (!mounted) return;
      navigator.pop(true);
    } catch (e) {
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.errorSaving}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteProfile() async {
    if (!_isEditing || widget.profile == null) return;
    if (!context.mounted) return;

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
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.errorDeleting}: $e'),
            backgroundColor: Colors.red,
          ),
        );
        }
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    if (!mounted) return;
    if (!context.mounted) return;
    
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
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    safeSetState(() {
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

    if (newPhotoPath != null) {
      safeSetState(() {
        _photoPath = newPhotoPath;
        _photoDeleted = false; // Сбрасываем флаг, так как выбрано новое фото
      });
    }
  }

  // Защищённый setState
  void safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }
  
  void _onThemeChanged() {
    safeSetState(() {});
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
          children: [
            // Карточка с полями
            Container(
              width: double.infinity,
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
                                )
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
                        safeSetState(() {}); // Обновляем только текст инициала, цвет не меняется
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
                        final localizations = AppLocalizations.of(context);
                        if (value == null || value.trim().isEmpty) {
                          return localizations.pleaseEnterName;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    // Поле выбора даты рождения
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]!
                                : Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context).birthdate,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.secondaryTextColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedDate != null
                                        ? formatDate(_selectedDate!, Localizations.localeOf(context))
                                        : AppLocalizations.of(context).selectDate,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _selectedDate != null
                                          ? context.textColor
                                          : context.secondaryTextColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              LucideIcons.calendar,
                              color: _primaryColor,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final dateError = _validateDate();
                        if (dateError != null && _selectedDate != null) {
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
                          color: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]!
                                : Colors.grey[200]!,
                            width: 1,
                          ),
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
                                              name: AppLocalizations.of(context).unknownGroup,
                                              createdAt: DateTime.now(),
                                            ),
                                          ).name
                                        : AppLocalizations.of(context).noGroup,
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
                    const SizedBox(height: 28),
                    // Кнопка удаления (только при редактировании)
                    if (_isEditing) ...[
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: _deleteProfile,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ).copyWith(
                            splashFactory: NoSplash.splashFactory,
                          ),
                          child: Text(
                            AppLocalizations.of(context).delete,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

