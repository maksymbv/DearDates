import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

String formatDate(DateTime date, [Locale? locale]) {
  final localeString = _getLocaleString(locale);
  return DateFormat('dd.MM.yyyy', localeString).format(date);
}

String formatDateShort(DateTime date, [Locale? locale]) {
  // Форматирование в формате "1 January" (день + месяц)
  final localeString = _getLocaleString(locale);
  return DateFormat('d MMMM', localeString).format(date);
}

String formatDateFull(DateTime date, [Locale? locale]) {
  // Форматирование в формате "1 January 2005" (день + месяц + год)
  final localeString = _getLocaleString(locale);
  return DateFormat('d MMMM yyyy', localeString).format(date);
}

String _getLocaleString(Locale? locale) {
  if (locale == null) return 'en_US';
  
  // Преобразуем Locale в строку для intl
  switch (locale.languageCode) {
    case 'ru':
      return 'ru_RU';
    case 'uk':
      return 'uk_UA';
    case 'en':
    default:
      return 'en_US';
  }
}

int getAge(DateTime birthdate) {
  final now = DateTime.now();
  int age = now.year - birthdate.year;
  if (now.month < birthdate.month ||
      (now.month == birthdate.month && now.day < birthdate.day)) {
    age--;
  }
  return age;
}

DateTime calculateNextBirthday(DateTime birthdate) {
  final now = DateTime.now();
  // Нормализуем текущую дату до начала дня для корректного сравнения
  final today = DateTime(now.year, now.month, now.day);
  
  // Обработка високосных годов для 29 февраля
  int day = birthdate.day;
  int month = birthdate.month;
  
  // Если день рождения 29 февраля, обрабатываем високосный год
  if (month == 2 && day == 29) {
    // Пытаемся создать дату для текущего года
    DateTime currentYearBirthday;
    try {
      currentYearBirthday = DateTime(now.year, month, day);
    } catch (e) {
      // Если текущий год не високосный, используем 28 февраля
      currentYearBirthday = DateTime(now.year, 2, 28);
    }
    
    // Если день рождения сегодня, возвращаем сегодняшнюю дату
    if (currentYearBirthday.isAtSameMomentAs(today)) {
      return currentYearBirthday;
    }
    
    // Если день рождения уже прошел в этом году, переходим к следующему году
    if (currentYearBirthday.isBefore(today)) {
      try {
        return DateTime(now.year + 1, month, day);
      } catch (e) {
        // Если следующий год тоже не високосный, используем 28 февраля
        return DateTime(now.year + 1, 2, 28);
      }
    }
    
    return currentYearBirthday;
  }
  
  // Обычная обработка для других дат
  var nextBirthday = DateTime(now.year, month, day);
  
  // Если день рождения сегодня, возвращаем сегодняшнюю дату
  if (nextBirthday.isAtSameMomentAs(today)) {
    return nextBirthday;
  }
  
  // Если день рождения уже прошел, переходим к следующему году
  if (nextBirthday.isBefore(today)) {
    nextBirthday = DateTime(now.year + 1, month, day);
  }
  
  return nextBirthday;
}

int daysUntilBirthday(DateTime birthdate) {
  final nextBirthday = calculateNextBirthday(birthdate);
  final now = DateTime.now();
  // Нормализуем обе даты до начала дня для корректного подсчета
  final today = DateTime(now.year, now.month, now.day);
  final birthdayNormalized = DateTime(nextBirthday.year, nextBirthday.month, nextBirthday.day);
  final difference = birthdayNormalized.difference(today);
  return difference.inDays;
}

/// Возвращает строку с возрастом, который исполнится на день рождения
String getBirthdayAgeText(DateTime birthdate, BuildContext context) {
  final localizations = AppLocalizations.of(context);
  final currentAge = getAge(birthdate);
  final nextBirthdayAge = currentAge + 1;
  final locale = Localizations.localeOf(context);
  final birthdayDate = formatDateShort(birthdate, locale);
  
  // Используем локализованные строки
  final turnsText = _getTurnsText(localizations);
  final ageText = _getAgeText(nextBirthdayAge, localizations);
  return '$birthdayDate $turnsText $nextBirthdayAge $ageText';
}

String _getAgeText(int age, AppLocalizations localizations) {
  final langCode = localizations.locale.languageCode;
  
  if (langCode == 'ru') {
    // Русский: 1, 21, 31... → "год"; 2-4, 22-24, 32-34... → "года"; остальные → "лет"
    final lastDigit = age % 10;
    final lastTwoDigits = age % 100;
    
    if (lastTwoDigits >= 11 && lastTwoDigits <= 14) {
      return 'лет';
    } else if (lastDigit == 1) {
      return 'год';
    } else if (lastDigit >= 2 && lastDigit <= 4) {
      return 'года';
    } else {
      return 'лет';
    }
  } else if (langCode == 'uk') {
    // Украинский: 1, 21, 31... → "рік"; 2-4, 22-24, 32-34... → "роки"; остальные → "років"
    final lastDigit = age % 10;
    final lastTwoDigits = age % 100;
    
    if (lastTwoDigits >= 11 && lastTwoDigits <= 14) {
      return 'років';
    } else if (lastDigit == 1) {
      return 'рік';
    } else if (lastDigit >= 2 && lastDigit <= 4) {
      return 'роки';
    } else {
      return 'років';
    }
  } else {
    // Английский
    return age == 1 ? localizations.year : localizations.years;
  }
}

String _getTurnsText(AppLocalizations localizations) {
  // Для разных языков может быть разный текст
  final langCode = localizations.locale.languageCode;
  if (langCode == 'ru') {
    return 'исполнится';
  } else if (langCode == 'uk') {
    return 'виповниться';
  } else {
    return 'turns';
  }
}

/// Возвращает правильную форму слова "день/дня/дней" в зависимости от количества дней
/// Поддерживает английский, русский и украинский языки
String pluralDays(int days, AppLocalizations loc) {
  final lang = loc.locale.languageCode;
  
  if (lang == 'en') {
    return days == 1 ? loc.day : loc.days;
  }
  
  if (lang == 'ru' || lang == 'uk') {
    // Для русского и украинского используем склонения
    // 1, 21, 31... → "день" / "день"
    if (days % 10 == 1 && days % 100 != 11) {
      return loc.day;
    }
    
    // 2-4, 22-24, 32-34... → "дня" / "дні"
    if (days % 10 >= 2 && days % 10 <= 4 && 
        (days % 100 < 10 || days % 100 >= 20)) {
      return loc.days;
    }
    
    // Остальные → "дней" / "днів"
    return loc.days;
  }
  
  // Fallback для других языков
  return days == 1 ? loc.day : loc.days;
}

