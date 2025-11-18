import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/group.dart';

class GroupService {
  static final GroupService _instance = GroupService._internal();
  
  factory GroupService() => _instance;
  GroupService._internal();
  
  static const String _groupsKey = 'groups';
  static const String _defaultGroupId = 'no_group';

  // Получить все группы
  Future<List<Group>> getAllGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final groupsJson = prefs.getStringList(_groupsKey);

    if (groupsJson == null || groupsJson.isEmpty) {
      return [];
    }

    final groups = groupsJson
        .map((json) => Group.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();

    // Сортируем по порядку
    groups.sort((a, b) => a.order.compareTo(b.order));

    return groups;
  }

  // Сохранить все группы
  Future<void> _saveGroups(List<Group> groups) async {
    final prefs = await SharedPreferences.getInstance();
    final groupsJson = groups
        .map((group) => jsonEncode(group.toJson()))
        .toList();
    await prefs.setStringList(_groupsKey, groupsJson);
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

    groups.add(newGroup);
    await _saveGroups(groups);
    return newGroup;
  }

  // Обновить группу
  Future<void> updateGroup(Group group) async {
    final groups = await getAllGroups();
    final index = groups.indexWhere((g) => g.id == group.id);
    
    if (index != -1) {
      groups[index] = group;
      await _saveGroups(groups);
    }
  }

  // Удалить группу
  Future<void> deleteGroup(String groupId) async {
    final groups = await getAllGroups();
    groups.removeWhere((g) => g.id == groupId);
    await _saveGroups(groups);
  }

  // Получить группу по ID
  Future<Group?> getGroupById(String? groupId) async {
    if (groupId == null) return null;
    
    final groups = await getAllGroups();
    try {
      return groups.firstWhere((g) => g.id == groupId);
    } catch (e) {
      return null;
    }
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

