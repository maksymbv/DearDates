import 'package:timezone/timezone.dart' as tz;
import '../models/profile.dart';
import '../utils/date_utils.dart';

class BirthdayDateHelper {
  static tz.TZDateTime nextBirthdayAt10(Profile profile) {
    final next = calculateNextBirthday(profile.birthdate);
    return tz.TZDateTime(
      tz.local,
      next.year,
      next.month,
      next.day,
      10, // 10:00 утра
      0,
    );
  }

  static bool isInFuture(tz.TZDateTime date) {
    return date.isAfter(tz.TZDateTime.now(tz.local));
  }
}

