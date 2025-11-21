import '../l10n/app_localizations.dart';
import '../utils/date_utils.dart' show formatDate, pluralDays;

class NotificationTextBuilder {
  final AppLocalizations loc;

  NotificationTextBuilder(this.loc);

  String titleForBirthday() => loc.birthdayToday;

  String bodyForBirthday(String name) =>
      loc.birthdayTodayBody.replaceAll('{name}', name);

  String titleForReminder() => loc.birthdaySoon;

  String bodyForReminder(String name, int days, DateTime birthday) {
    final daysText = pluralDays(days, loc);
    final locale = loc.locale;
    final date = formatDate(birthday, locale);
    return loc.birthdayReminderBody
        .replaceAll('{days}', days.toString())
        .replaceAll('{daysText}', daysText)
        .replaceAll('{name}', name)
        .replaceAll('{date}', date);
  }
}

