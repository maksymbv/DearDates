import 'package:hive/hive.dart';

part 'profile.g.dart';

@HiveType(typeId: 0)
class Profile extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final DateTime birthdate;
  
  @HiveField(3)
  final String? notes;
  
  @HiveField(4)
  final DateTime createdAt;
  
  @HiveField(5)
  final List<Gift> gifts;
  
  @HiveField(6)
  final int avatarColor; // Цвет аватара (пастельный)
  
  @HiveField(7)
  final String? photoPath; // Путь к фото профиля
  
  @HiveField(8)
  final String? groupId; // ID группы, к которой принадлежит профиль

  Profile({
    required this.id,
    required this.name,
    required this.birthdate,
    this.notes,
    required this.createdAt,
    this.gifts = const [],
    required this.avatarColor,
    this.photoPath,
    this.groupId,
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
      'photoPath': photoPath,
      'groupId': groupId,
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
      photoPath: json['photoPath'] as String?,
      groupId: json['groupId'] as String?,
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
    String? photoPath,
    String? groupId,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      birthdate: birthdate ?? this.birthdate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      gifts: gifts ?? this.gifts,
      avatarColor: avatarColor ?? this.avatarColor,
      photoPath: photoPath ?? this.photoPath,
      groupId: groupId ?? this.groupId,
    );
  }
}

@HiveType(typeId: 1)
class Gift extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String profileId;
  
  @HiveField(2)
  final String idea;
  
  @HiveField(3)
  final String? description; // Описание идеи подарка
  
  @HiveField(4)
  final bool isGiven;
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  final int? givenYear; // Год, когда был подарен подарок

  Gift({
    required this.id,
    required this.profileId,
    required this.idea,
    this.description,
    this.isGiven = false,
    required this.createdAt,
    this.givenYear,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profileId': profileId,
      'idea': idea,
      'description': description,
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
      description: json['description'] as String?,
      isGiven: json['isGiven'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      givenYear: json['givenYear'] as int?,
    );
  }

  Gift copyWith({
    String? id,
    String? profileId,
    String? idea,
    String? description,
    bool? isGiven,
    DateTime? createdAt,
    int? givenYear,
  }) {
    return Gift(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      idea: idea ?? this.idea,
      description: description ?? this.description,
      isGiven: isGiven ?? this.isGiven,
      createdAt: createdAt ?? this.createdAt,
      givenYear: givenYear ?? this.givenYear,
    );
  }
}

