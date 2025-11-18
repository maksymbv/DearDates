import '../models/profile.dart';

/// Класс для элементов списка (заголовок или профиль)
class ListItem {
  final bool isHeader;
  final String? groupId;
  final Profile? profile;

  ListItem({
    required this.isHeader,
    this.groupId,
    this.profile,
  });
}

