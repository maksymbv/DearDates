import '../localization/app_localizations.dart';
import '../utils/date_utils.dart';

class NotificationTextBuilder {
  final AppLocalizations loc;

  NotificationTextBuilder(this.loc);

  String titleForBirthday() => loc.birthdayToday;

  String bodyForBirthday(String name) =>
      loc.birthdayTodayBody.replaceAll('{name}', name);

  String titleForReminder() => loc.birthdaySoon;

  String bodyForReminder(String name, int days, DateTime birthday) {
    final daysText = _plural(days);
    final locale = loc.locale;
    final date = formatDate(birthday, locale);
    return loc.birthdayReminderBody
        .replaceAll('{days}', days.toString())
        .replaceAll('{daysText}', daysText)
        .replaceAll('{name}', name)
        .replaceAll('{date}', date);
  }

  String _plural(int days) {
    // Для английского языка
    if (loc.locale.languageCode == 'en') {
      return days == 1 ? loc.day : loc.days;
    }
    
    // Для русского и украинского используем склонения
    // 1, 21, 31... → "день"
    if (days % 10 == 1 && days % 100 != 11) {
      return loc.day;
    }
    
    // 2-4, 22-24, 32-34... → "дня"
    if (days % 10 >= 2 && days % 10 <= 4 && 
        (days % 100 < 10 || days % 100 >= 20)) {
      return loc.days;
    }
    
    // Остальные → "дней"
    return loc.days;
  }
}

