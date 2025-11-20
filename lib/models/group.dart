import 'package:hive/hive.dart';

part 'group.g.dart';

@HiveType(typeId: 2)
class Group extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final DateTime createdAt;
  
  @HiveField(3)
  final int order; // Порядок сортировки

  Group({
    required this.id,
    required this.name,
    required this.createdAt,
    this.order = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'order': order,
    };
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      order: json['order'] as int? ?? 0,
    );
  }

  Group copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    int? order,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      order: order ?? this.order,
    );
  }
}

