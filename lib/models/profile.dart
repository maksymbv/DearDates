class Profile {
  final String id;
  final String name;
  final DateTime birthdate;
  final String? notes;
  final DateTime createdAt;
  final List<Gift> gifts;
  final int avatarColor; // Цвет аватара (пастельный)

  Profile({
    required this.id,
    required this.name,
    required this.birthdate,
    this.notes,
    required this.createdAt,
    this.gifts = const [],
    required this.avatarColor,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthdate': birthdate.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'gifts': gifts.map((g) => g.toJson()).toList(),
      'avatarColor': avatarColor,
    };
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      name: json['name'] as String,
      birthdate: DateTime.parse(json['birthdate'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      gifts: (json['gifts'] as List<dynamic>?)
              ?.map((g) => Gift.fromJson(g as Map<String, dynamic>))
              .toList() ??
          [],
      avatarColor: json['avatarColor'] as int? ?? 0xFFD68A9E, // По умолчанию розовый для старых профилей
    );
  }

  Profile copyWith({
    String? id,
    String? name,
    DateTime? birthdate,
    String? notes,
    DateTime? createdAt,
    List<Gift>? gifts,
    int? avatarColor,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      birthdate: birthdate ?? this.birthdate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      gifts: gifts ?? this.gifts,
      avatarColor: avatarColor ?? this.avatarColor,
    );
  }
}

class Gift {
  final String id;
  final String profileId;
  final String idea;
  final bool isGiven;
  final DateTime createdAt;
  final int? givenYear; // Год, когда был подарен подарок

  Gift({
    required this.id,
    required this.profileId,
    required this.idea,
    this.isGiven = false,
    required this.createdAt,
    this.givenYear,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profileId': profileId,
      'idea': idea,
      'isGiven': isGiven,
      'createdAt': createdAt.toIso8601String(),
      'givenYear': givenYear,
    };
  }

  factory Gift.fromJson(Map<String, dynamic> json) {
    return Gift(
      id: json['id'] as String,
      profileId: json['profileId'] as String,
      idea: json['idea'] as String,
      isGiven: json['isGiven'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      givenYear: json['givenYear'] as int?,
    );
  }

  Gift copyWith({
    String? id,
    String? profileId,
    String? idea,
    bool? isGiven,
    DateTime? createdAt,
    int? givenYear,
  }) {
    return Gift(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      idea: idea ?? this.idea,
      isGiven: isGiven ?? this.isGiven,
      createdAt: createdAt ?? this.createdAt,
      givenYear: givenYear ?? this.givenYear,
    );
  }
}

