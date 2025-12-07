import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    try {
      final localizations = Localizations.of<AppLocalizations>(
        context,
        AppLocalizations,
      );
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

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Получить строку для текущей локали (или английский по умолчанию)
  String _getString(String key) {
    // Сначала пытаемся получить из текущей локали
    final currentLocaleMap = _localizedValues[locale.languageCode];
    if (currentLocaleMap != null && currentLocaleMap.containsKey(key)) {
      return currentLocaleMap[key]!;
    }

    // Если не найдено, используем английский
    final englishMap = _localizedValues['en'];
    if (englishMap != null && englishMap.containsKey(key)) {
      return englishMap[key]!;
    }

    // Если ключ вообще не найден, возвращаем сам ключ
    return key;
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
  String get useDefaultNotifications => _getString('useDefaultNotifications');
  String get usingDefaultNotifications => _getString('usingDefaultNotifications');
  String get currentSettings => _getString('currentSettings');
  String get enableNotifications => _getString('enableNotifications');

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
  String get previewPhoto => _getString('previewPhoto');
  String get apply => _getString('apply');

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
  String get birthdays => _getString('birthdays');
  String get noBirthdaysInMonth => _getString('noBirthdaysInMonth');
  String get notificationChannelName => _getString('notificationChannelName');
  String get notificationChannelDescription =>
      _getString('notificationChannelDescription');

  // Настройки темы
  String get displayMode => _getString('displayMode');
  String get selectLightOrDark => _getString('selectLightOrDark');
  String get darkTheme => _getString('darkTheme');
  String get lightTheme => _getString('lightTheme');
  String get accentColor => _getString('accentColor');
  String get selectColorScheme => _getString('selectColorScheme');

  // Валидация и ошибки
  String get pleaseSelectBirthdate => _getString('pleaseSelectBirthdate');
  String get dateCannotBeFuture => _getString('dateCannotBeFuture');
  String get pleaseEnterName => _getString('pleaseEnterName');
  String get selectDate => _getString('selectDate');
  String get errorSaving => _getString('errorSaving');
  String get errorDeleting => _getString('errorDeleting');
  String get profileNotFound => _getString('profileNotFound');
  String get unknownGroup => _getString('unknownGroup');

  // Подарки
  String get saveChanges => _getString('saveChanges');
  String get deleteIdea => _getString('deleteIdea');
  String get idea => _getString('idea');
  String get description => _getString('description');

  // О приложении
  String get madeBy => _getString('madeBy');

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
      'notificationSettings': 'Notifications',
      'reminderDaysTitle': 'Reminder Days',
      'reminderDaysDescription':
          'Select how many days before the birthday you want to receive notifications',
      'birthdayNotificationInfo':
          'You will also receive a notification on the birthday itself',
      'useDefaultNotifications': 'Use default notifications',
      'usingDefaultNotifications': 'Using global notification settings',
      'currentSettings': 'Current settings',
      'enableNotifications': 'Notifications',
      'addProfile': 'Add Profile',
      'editProfile': 'Edit Profile',
      'deleteProfile': 'Delete Profile',
      'name': 'Name',
      'birthdate': 'Birthdate',
      'notes': 'Notes',
      'group': 'Group',
      'noGroup': 'All',
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
      'previewPhoto': 'Preview Photo',
      'apply': 'Apply',
      'yearsOld': 'years old',
      'year': 'year',
      'years': 'years',
      'today': 'Today',
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
      'deleteGroupMessage':
          'The group "{groupName}" contains {count} {profileText}. They will be moved to "All". Continue?',
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
      'birthdayReminderBody':
          'In {days} {daysText} {name}\'s birthday ({date})',
      'birthdays': 'Birthdays',
      'noBirthdaysInMonth': 'No birthdays in this month',
      'notificationChannelName': 'Birthday Reminders',
      'notificationChannelDescription':
          'Notifications about upcoming birthdays',
      'displayMode': 'Dark Mode',
      'selectLightOrDark': 'Enable or disable dark theme',
      'darkTheme': 'Dark Theme',
      'lightTheme': 'Light Theme',
      'accentColor': 'Accent Color',
      'selectColorScheme': 'Choose app color scheme',
      'pleaseSelectBirthdate': 'Please select birthdate',
      'dateCannotBeFuture': 'Date cannot be in the future',
      'pleaseEnterName': 'Please enter name',
      'selectDate': 'Select date',
      'errorSaving': 'Error saving',
      'errorDeleting': 'Error deleting',
      'profileNotFound': 'Profile not found',
      'unknownGroup': 'Unknown group',
      'saveChanges': 'Save changes',
      'deleteIdea': 'Delete idea',
      'idea': 'Idea',
      'description': 'Description',
      'madeBy': 'Made for special dates ✨',
    },
    'ru': {
      'settings': 'Настройки',
      'notifications': 'Уведомления',
      'theme': 'Тема',
      'language': 'Язык',
      'light': 'Светлая',
      'dark': 'Темная',
      'pink': 'Розовая',
      'blue': 'Синяя',
      'russian': 'Русский',
      'english': 'English',
      'ukrainian': 'Українська',
      'notSelected': 'Не выбрано',
      'daysBefore': 'За',
      'day': 'день',
      'days': 'дней',
      'notificationSettings': 'Уведомления',
      'reminderDaysTitle': 'Дни напоминания',
      'reminderDaysDescription':
          'Выберите за сколько дней до дня рождения вы хотите получать уведомления',
      'birthdayNotificationInfo':
          'Вы также получите уведомление в сам день рождения',
      'useDefaultNotifications': 'Использовать стандартные уведомления',
      'usingDefaultNotifications': 'Используются глобальные настройки уведомлений',
      'currentSettings': 'Текущие настройки',
      'enableNotifications': 'Уведомления',
      'addProfile': 'Добавить профиль',
      'editProfile': 'Редактировать профиль',
      'deleteProfile': 'Удалить профиль',
      'name': 'Имя',
      'birthdate': 'Дата рождения',
      'notes': 'Заметки',
      'group': 'Группа',
      'noGroup': 'Все',
      'save': 'Сохранить',
      'cancel': 'Отмена',
      'done': 'Готово',
      'delete': 'Удалить',
      'edit': 'Редактировать',
      'giftIdeas': 'Идеи подарков',
      'alreadyGiven': 'Уже подарено',
      'addIdea': 'Добавить идею',
      'all': 'Все',
      'createGroup': 'Создать группу',
      'editGroup': 'Редактировать группу',
      'groupName': 'Название группы',
      'search': 'Поиск',
      'searchHint': 'Поиск...',
      'noProfiles': 'Нет профилей',
      'noGifts': 'Нет идей подарков',
      'deleteProfileConfirm': 'Удалить профиль',
      'deleteGiftConfirm': 'Удалить идею подарка?',
      'deleteGroupConfirm': 'Удалить группу?',
      'cannotRestore':
          'Все данные будут удалены и не могут быть восстановлены.',
      'selectFromGallery': 'Выбрать из галереи',
      'takePhoto': 'Сделать фото',
      'deletePhoto': 'Удалить фото',
      'previewPhoto': 'Предпросмотр фото',
      'apply': 'Применить',
      'yearsOld': 'лет',
      'year': 'год',
      'years': 'лет',
      'today': 'Сегодня',
      'daysUntil': 'Через',
      'create': 'Создать',
      'editAction': 'Редактировать',
      'dayField': 'День',
      'monthField': 'Месяц',
      'yearField': 'Год',
      'profileSingular': 'профиль',
      'profilePlural2': 'профиля',
      'profilePlural': 'профилей',
      'deleteProfileWithName': 'Удалить профиль',
      'deleteGroupMessage':
          'Группа "{groupName}" содержит {count} {profileText}. Они будут перемещены в "Все". Продолжить?',
      'continueAction': 'Продолжить',
      'areYouSure': 'Вы уверены?',
      'noGiftsYet': 'Пока нет идей подарков',
      'addFirst': 'Добавьте первую!',
      'noProfilesYet': 'Пока нет профилей',
      'addFirstProfile': 'Добавьте первый профиль!',
      'nothingFound': 'Ничего не найдено',
      'tryDifferentQuery': 'Попробуйте другой запрос',
      'found': 'Найдено',
      'selectGroup': 'Выбрать группу',
      'birthdaySoon': 'Скоро день рождения! 🎂',
      'birthdayToday': 'День рождения сегодня! 🎉',
      'birthdayTodayBody': 'Сегодня день рождения {name}!',
      'birthdayReminderBody':
          'Через {days} {daysText} день рождения {name} ({date})',
      'birthdays': 'Дни рождения',
      'noBirthdaysInMonth': 'Нет дней рождения в этом месяце',
      'notificationChannelName': 'Напоминания о днях рождения',
      'notificationChannelDescription':
          'Уведомления о предстоящих днях рождения',
      'displayMode': 'Темный режим',
      'selectLightOrDark': 'Включить или выключить темную тему',
      'darkTheme': 'Темная тема',
      'lightTheme': 'Светлая тема',
      'accentColor': 'Акцентный цвет',
      'selectColorScheme': 'Выберите цветовую схему приложения',
      'pleaseSelectBirthdate': 'Пожалуйста, выберите дату рождения',
      'dateCannotBeFuture': 'Дата не может быть в будущем',
      'pleaseEnterName': 'Пожалуйста, введите имя',
      'selectDate': 'Выбрать дату',
      'errorSaving': 'Ошибка при сохранении',
      'errorDeleting': 'Ошибка при удалении',
      'profileNotFound': 'Профиль не найден',
      'unknownGroup': 'Неизвестная группа',
      'saveChanges': 'Сохранить изменения',
      'deleteIdea': 'Удалить идею',
      'idea': 'Идея',
      'description': 'Описание',
      'madeBy': 'Создано для особенных дат ✨',
    },
    'uk': {
      'settings': 'Налаштування',
      'notifications': 'Сповіщення',
      'theme': 'Тема',
      'language': 'Мова',
      'light': 'Світла',
      'dark': 'Темна',
      'pink': 'Рожева',
      'blue': 'Синя',
      'russian': 'Русский',
      'english': 'English',
      'ukrainian': 'Українська',
      'notSelected': 'Не вибрано',
      'daysBefore': 'За',
      'day': 'день',
      'days': 'днів',
      'notificationSettings': 'Сповіщення',
      'reminderDaysTitle': 'Дні нагадування',
      'reminderDaysDescription':
          'Виберіть за скільки днів до дня народження ви хочете отримувати сповіщення',
      'birthdayNotificationInfo':
          'Ви також отримаєте сповіщення в сам день народження',
      'useDefaultNotifications': 'Використовувати стандартні сповіщення',
      'usingDefaultNotifications': 'Використовуються глобальні налаштування сповіщень',
      'currentSettings': 'Поточні налаштування',
      'enableNotifications': 'Сповіщення',
      'addProfile': 'Додати профіль',
      'editProfile': 'Редагувати профіль',
      'deleteProfile': 'Видалити профіль',
      'name': 'Ім\'я',
      'birthdate': 'Дата народження',
      'notes': 'Нотатки',
      'group': 'Група',
      'noGroup': 'Всі',
      'save': 'Зберегти',
      'cancel': 'Скасувати',
      'done': 'Готово',
      'delete': 'Видалити',
      'edit': 'Редагувати',
      'giftIdeas': 'Ідеї подарунків',
      'alreadyGiven': 'Вже подаровано',
      'addIdea': 'Додати ідею',
      'all': 'Всі',
      'createGroup': 'Створити групу',
      'editGroup': 'Редагувати групу',
      'groupName': 'Назва групи',
      'search': 'Пошук',
      'searchHint': 'Пошук...',
      'noProfiles': 'Немає профілів',
      'noGifts': 'Немає ідей подарунків',
      'deleteProfileConfirm': 'Видалити профіль',
      'deleteGiftConfirm': 'Видалити ідею подарунка?',
      'deleteGroupConfirm': 'Видалити групу?',
      'cannotRestore': 'Всі дані будуть видалені і не можуть бути відновлені.',
      'selectFromGallery': 'Вибрати з галереї',
      'takePhoto': 'Зробити фото',
      'deletePhoto': 'Видалити фото',
      'previewPhoto': 'Попередній перегляд фото',
      'apply': 'Застосувати',
      'yearsOld': 'років',
      'year': 'рік',
      'years': 'років',
      'today': 'Сьогодні',
      'daysUntil': 'Через',
      'create': 'Створити',
      'editAction': 'Редагувати',
      'dayField': 'День',
      'monthField': 'Місяць',
      'yearField': 'Рік',
      'profileSingular': 'профіль',
      'profilePlural2': 'профілі',
      'profilePlural': 'профілів',
      'deleteProfileWithName': 'Видалити профіль',
      'deleteGroupMessage':
          'Група "{groupName}" містить {count} {profileText}. Вони будуть переміщені в "Всі". Продовжити?',
      'continueAction': 'Продовжити',
      'areYouSure': 'Ви впевнені?',
      'noGiftsYet': 'Поки немає ідей подарунків',
      'addFirst': 'Додайте першу!',
      'noProfilesYet': 'Поки немає профілів',
      'addFirstProfile': 'Додайте перший профіль!',
      'nothingFound': 'Нічого не знайдено',
      'tryDifferentQuery': 'Спробуйте інший запит',
      'found': 'Знайдено',
      'selectGroup': 'Вибрати групу',
      'birthdaySoon': 'Незабаром день народження! 🎂',
      'birthdayToday': 'День народження сьогодні! 🎉',
      'birthdayTodayBody': 'Сьогодні день народження {name}!',
      'birthdayReminderBody':
          'Через {days} {daysText} день народження {name} ({date})',
      'birthdays': 'Дні народження',
      'noBirthdaysInMonth': 'Немає днів народження в цьому місяці',
      'notificationChannelName': 'Нагадування про дні народження',
      'notificationChannelDescription':
          'Сповіщення про майбутні дні народження',
      'displayMode': 'Темний режим',
      'selectLightOrDark': 'Увімкнути або вимкнути темну тему',
      'darkTheme': 'Темна тема',
      'lightTheme': 'Світла тема',
      'accentColor': 'Акцентний колір',
      'selectColorScheme': 'Виберіть колірну схему додатку',
      'pleaseSelectBirthdate': 'Будь ласка, виберіть дату народження',
      'dateCannotBeFuture': 'Дата не може бути в майбутньому',
      'pleaseEnterName': 'Будь ласка, введіть ім\'я',
      'selectDate': 'Вибрати дату',
      'errorSaving': 'Помилка при збереженні',
      'errorDeleting': 'Помилка при видаленні',
      'profileNotFound': 'Профіль не знайдено',
      'unknownGroup': 'Невідома група',
      'saveChanges': 'Зберегти зміни',
      'deleteIdea': 'Видалити ідею',
      'idea': 'Ідея',
      'description': 'Опис',
      'madeBy': 'Створено для особливих дат ✨',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Поддерживаем английский, русский и украинский
    return ['en', 'ru', 'uk'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // Если язык не поддерживается, используем английский
    final supportedLocale = isSupported(locale)
        ? locale
        : const Locale('en', 'US');
    return AppLocalizations(supportedLocale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
