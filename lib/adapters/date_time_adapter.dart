import 'package:hive/hive.dart';

class DateTimeAdapter extends TypeAdapter<DateTime> {
  @override
  final int typeId = 100; // Используем большой typeId, чтобы не конфликтовать с моделями

  @override
  DateTime read(BinaryReader reader) {
    // В Hive 2.x используем read() для чтения данных
    final value = reader.read();
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is String) {
      return DateTime.parse(value);
    } else {
      throw Exception('Invalid DateTime format in Hive: $value');
    }
  }

  @override
  void write(BinaryWriter writer, DateTime obj) {
    // Сохраняем как строку ISO8601 для надежности и совместимости
    writer.write(obj.toIso8601String());
  }
}

