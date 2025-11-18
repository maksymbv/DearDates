class Group {
  final String id;
  final String name;
  final DateTime createdAt;
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

