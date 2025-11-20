// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfileAdapter extends TypeAdapter<Profile> {
  @override
  final int typeId = 0;

  @override
  Profile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Profile(
      id: fields[0] as String,
      name: fields[1] as String,
      birthdate: fields[2] as DateTime,
      notes: fields[3] as String?,
      createdAt: fields[4] as DateTime,
      gifts: (fields[5] as List).cast<Gift>(),
      avatarColor: fields[6] as int,
      photoPath: fields[7] as String?,
      groupId: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Profile obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.birthdate)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.gifts)
      ..writeByte(6)
      ..write(obj.avatarColor)
      ..writeByte(7)
      ..write(obj.photoPath)
      ..writeByte(8)
      ..write(obj.groupId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GiftAdapter extends TypeAdapter<Gift> {
  @override
  final int typeId = 1;

  @override
  Gift read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Gift(
      id: fields[0] as String,
      profileId: fields[1] as String,
      idea: fields[2] as String,
      description: fields[3] as String?,
      isGiven: fields[4] as bool,
      createdAt: fields[5] as DateTime,
      givenYear: fields[6] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Gift obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.profileId)
      ..writeByte(2)
      ..write(obj.idea)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.isGiven)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.givenYear);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GiftAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
