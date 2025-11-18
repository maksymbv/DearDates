String formatDate(DateTime date) {
  // Встроенное форматирование без intl
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  return '$day.$month.$year';
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
    
    // Если день рождения уже прошел в этом году, переходим к следующему году
    if (currentYearBirthday.isBefore(today) || currentYearBirthday.isAtSameMomentAs(today)) {
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
  
  // Сравниваем только даты (без времени)
  if (nextBirthday.isBefore(today) || nextBirthday.isAtSameMomentAs(today)) {
    nextBirthday = DateTime(now.year + 1, month, day);
  }
  
  return nextBirthday;
}

int daysUntilBirthday(DateTime birthdate) {
  final nextBirthday = calculateNextBirthday(birthdate);
  final now = DateTime.now();
  final difference = nextBirthday.difference(now);
  return difference.inDays;
}

