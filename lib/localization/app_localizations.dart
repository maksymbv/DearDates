import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    try {
      final localizations = Localizations.of<AppLocalizations>(context, AppLocalizations);
      if (localizations != null) {
        return localizations;
      }
    } catch (e) {
      // Игнорируем ошибки при hot reload или если контекст еще не готов
    }
    
    // Fallback: получаем locale из контекста или используем английский по умолчанию
    try {
      final locale = Localizations.localeOf(context);
      return AppLocalizations(locale);
    } catch (e) {
      // Если и это не работает, возвращаем английский
      return AppLocalizations(const Locale('en', 'US'));
    }
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  // Получить строку для текущей локали (или английский по умолчанию)
  String _getString(String key) {
    // Сейчас всегда возвращаем английский
    // В будущем можно легко добавить Map с переводами:
    // return _localizedValues[locale.languageCode]?[key] ?? _localizedValues['en']![key]!;
    return _localizedValues['en']![key]!;
  }
  
  // Основные экраны
  String get settings => _getString('settings');
  String get notifications => _getString('notifications');
  String get theme => _getString('theme');
  String get language => _getString('language');
  
  // Настройки темы
  String get light => _getString('light');
  String get dark => _getString('dark');
  String get pink => _getString('pink');
  String get blue => _getString('blue');
  
  // Языки (для будущего использования)
  String get russian => _getString('russian');
  String get english => _getString('english');
  String get ukrainian => _getString('ukrainian');
  
  // Уведомления
  String get notSelected => _getString('notSelected');
  String get daysBefore => _getString('daysBefore');
  String get day => _getString('day');
  String get days => _getString('days');
  String get notificationSettings => _getString('notificationSettings');
  String get reminderDaysTitle => _getString('reminderDaysTitle');
  String get reminderDaysDescription => _getString('reminderDaysDescription');
  String get birthdayNotificationInfo => _getString('birthdayNotificationInfo');
  
  // Профили
  String get addProfile => _getString('addProfile');
  String get editProfile => _getString('editProfile');
  String get deleteProfile => _getString('deleteProfile');
  String get name => _getString('name');
  String get birthdate => _getString('birthdate');
  String get notes => _getString('notes');
  String get group => _getString('group');
  String get noGroup => _getString('noGroup');
  String get save => _getString('save');
  String get cancel => _getString('cancel');
  String get done => _getString('done');
  String get delete => _getString('delete');
  String get edit => _getString('edit');
  
  // Подарки
  String get giftIdeas => _getString('giftIdeas');
  String get alreadyGiven => _getString('alreadyGiven');
  String get addIdea => _getString('addIdea');
  
  // Группы
  String get all => _getString('all');
  String get createGroup => _getString('createGroup');
  String get editGroup => _getString('editGroup');
  String get groupName => _getString('groupName');
  
  // Поиск
  String get search => _getString('search');
  String get searchHint => _getString('searchHint');
  
  // Пустые состояния
  String get noProfiles => _getString('noProfiles');
  String get noGifts => _getString('noGifts');
  
  // Подтверждения
  String get deleteProfileConfirm => _getString('deleteProfileConfirm');
  String get deleteGiftConfirm => _getString('deleteGiftConfirm');
  String get deleteGroupConfirm => _getString('deleteGroupConfirm');
  String get cannotRestore => _getString('cannotRestore');
  
  // Фото
  String get selectFromGallery => _getString('selectFromGallery');
  String get takePhoto => _getString('takePhoto');
  String get deletePhoto => _getString('deletePhoto');
  
  // Возраст
  String get yearsOld => _getString('yearsOld');
  String get year => _getString('year');
  String get years => _getString('years');
  
  // Дни до дня рождения
  String get today => _getString('today');
  String get daysUntil => _getString('daysUntil');
  
  // Дополнительные строки
  String get create => _getString('create');
  String get editAction => _getString('editAction');
  String get dayField => _getString('dayField');
  String get monthField => _getString('monthField');
  String get yearField => _getString('yearField');
  String get profileSingular => _getString('profileSingular');
  String get profilePlural2 => _getString('profilePlural2');
  String get profilePlural => _getString('profilePlural');
  String get deleteProfileWithName => _getString('deleteProfileWithName');
  String get deleteGroupMessage => _getString('deleteGroupMessage');
  String get continueAction => _getString('continueAction');
  String get areYouSure => _getString('areYouSure');
  String get noGiftsYet => _getString('noGiftsYet');
  String get addFirst => _getString('addFirst');
  String get noProfilesYet => _getString('noProfilesYet');
  String get addFirstProfile => _getString('addFirstProfile');
  String get nothingFound => _getString('nothingFound');
  String get tryDifferentQuery => _getString('tryDifferentQuery');
  String get found => _getString('found');
  String get selectGroup => _getString('selectGroup');
  
  // Уведомления
  String get birthdaySoon => _getString('birthdaySoon');
  String get birthdayToday => _getString('birthdayToday');
  String get birthdayTodayBody => _getString('birthdayTodayBody');
  String get birthdayReminderBody => _getString('birthdayReminderBody');
  String get notificationChannelName => _getString('notificationChannelName');
  String get notificationChannelDescription => _getString('notificationChannelDescription');
  
  // Настройки темы
  String get displayMode => _getString('displayMode');
  String get selectLightOrDark => _getString('selectLightOrDark');
  String get darkTheme => _getString('darkTheme');
  String get lightTheme => _getString('lightTheme');
  String get accentColor => _getString('accentColor');
  String get selectColorScheme => _getString('selectColorScheme');
  
  // Map с переводами (сейчас только английский, легко добавить другие языки)
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'settings': 'Settings',
      'notifications': 'Notifications',
      'theme': 'Theme',
      'language': 'Language',
      'light': 'Light',
      'dark': 'Dark',
      'pink': 'Pink',
      'blue': 'Blue',
      'russian': 'Русский',
      'english': 'English',
      'ukrainian': 'Українська',
      'notSelected': 'Not selected',
      'daysBefore': 'Before',
      'day': 'day',
      'days': 'days',
      'notificationSettings': 'Notification Settings',
      'reminderDaysTitle': 'Reminder Days',
      'reminderDaysDescription': 'Select how many days before the birthday you want to receive notifications',
      'birthdayNotificationInfo': 'You will also receive a notification on the birthday itself',
      'addProfile': 'Add Profile',
      'editProfile': 'Edit Profile',
      'deleteProfile': 'Delete Profile',
      'name': 'Name',
      'birthdate': 'Birthdate',
      'notes': 'Notes',
      'group': 'Group',
      'noGroup': 'No Group',
      'save': 'Save',
      'cancel': 'Cancel',
      'done': 'Done',
      'delete': 'Delete',
      'edit': 'Edit',
      'giftIdeas': 'Gift Ideas',
      'alreadyGiven': 'Already Given',
      'addIdea': 'Add Idea',
      'all': 'All',
      'createGroup': 'Create Group',
      'editGroup': 'Edit Group',
      'groupName': 'Group Name',
      'search': 'Search',
      'searchHint': 'Search...',
      'noProfiles': 'No profiles',
      'noGifts': 'No gift ideas',
      'deleteProfileConfirm': 'Delete Profile',
      'deleteGiftConfirm': 'Delete gift idea?',
      'deleteGroupConfirm': 'Delete group?',
      'cannotRestore': 'All data will be deleted and cannot be restored.',
      'selectFromGallery': 'Select from Gallery',
      'takePhoto': 'Take Photo',
      'deletePhoto': 'Delete Photo',
      'yearsOld': 'years old',
      'year': 'year',
      'years': 'years',
      'today': 'Birthday today!',
      'daysUntil': 'In',
      'create': 'Create',
      'editAction': 'Edit',
      'dayField': 'Day',
      'monthField': 'Month',
      'yearField': 'Year',
      'profileSingular': 'profile',
      'profilePlural2': 'profiles',
      'profilePlural': 'profiles',
      'deleteProfileWithName': 'Delete Profile',
      'deleteGroupMessage': 'The group "{groupName}" contains {count} {profileText}. They will be moved to "No Group". Continue?',
      'continueAction': 'Continue',
      'areYouSure': 'Are you sure?',
      'noGiftsYet': 'No gift ideas yet',
      'addFirst': 'Add the first one!',
      'noProfilesYet': 'No profiles yet',
      'addFirstProfile': 'Add the first profile!',
      'nothingFound': 'Nothing found',
      'tryDifferentQuery': 'Try a different query',
      'found': 'Found',
      'selectGroup': 'Select Group',
      'birthdaySoon': 'Birthday soon! 🎂',
      'birthdayToday': 'Birthday today! 🎉',
      'birthdayTodayBody': 'Today is {name}\'s birthday!',
      'birthdayReminderBody': 'In {days} {daysText} {name}\'s birthday ({date})',
      'notificationChannelName': 'Birthday Reminders',
      'notificationChannelDescription': 'Notifications about upcoming birthdays',
      'displayMode': 'Display Mode',
      'selectLightOrDark': 'Choose light or dark theme',
      'darkTheme': 'Dark Theme',
      'lightTheme': 'Light Theme',
      'accentColor': 'Accent Color',
      'selectColorScheme': 'Choose app color scheme',
    },
    // В будущем можно легко добавить другие языки:
    // 'ru': { ... },
    // 'uk': { ... },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Сейчас поддерживаем только английский, но структура готова для других языков
    return true;
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // Всегда возвращаем английский, но передаем locale для будущего использования
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
