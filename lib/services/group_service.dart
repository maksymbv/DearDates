import 'package:hive_flutter/hive_flutter.dart';
import '../models/group.dart';

class GroupService {
  static final GroupService _instance = GroupService._internal();
  
  factory GroupService() => _instance;
  GroupService._internal();
  
  static const String _defaultGroupId = 'no_group';
  
  Box<Group> get _groupsBox => Hive.box<Group>('groups');

  // Получить все группы
  Future<List<Group>> getAllGroups() async {
    final groups = _groupsBox.values.toList();
    // Сортируем по порядку
    groups.sort((a, b) => a.order.compareTo(b.order));
    return groups;
  }

  // Сохранить все группы
  Future<void> _saveGroups(List<Group> groups) async {
    await _groupsBox.clear();
    final Map<String, Group> groupsMap = {
      for (var group in groups) group.id: group
    };
    await _groupsBox.putAll(groupsMap);
  }

  // Создать новую группу
  Future<Group> createGroup(String name) async {
    final groups = await getAllGroups();
    final newGroup = Group(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
      order: groups.length,
    );

    await _groupsBox.put(newGroup.id, newGroup);
    return newGroup;
  }

  // Обновить группу
  Future<void> updateGroup(Group group) async {
    await _groupsBox.put(group.id, group);
  }

  // Удалить группу
  Future<void> deleteGroup(String groupId) async {
    await _groupsBox.delete(groupId);
  }

  // Получить группу по ID
  Future<Group?> getGroupById(String? groupId) async {
    if (groupId == null) return null;
    return _groupsBox.get(groupId);
  }

  // Получить ID группы "Без группы"
  String get noGroupId => _defaultGroupId;

  // Обновить порядок групп
  Future<void> updateGroupsOrder(List<Group> groups) async {
    // Обновляем порядок
    for (int i = 0; i < groups.length; i++) {
      groups[i] = groups[i].copyWith(order: i);
    }
    await _saveGroups(groups);
  }
}
