// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AddressAdapter extends TypeAdapter<Address> {
  @override
  final int typeId = 0;

  @override
  Address read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Address()
      ..district = fields[0] as String
      ..taluk = fields[1] as String
      ..hobli = fields[2] as String
      ..village = fields[3] as String;
  }

  @override
  void write(BinaryWriter writer, Address obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.district)
      ..writeByte(1)
      ..write(obj.taluk)
      ..writeByte(2)
      ..write(obj.hobli)
      ..writeByte(3)
      ..write(obj.village);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class KYCAdapter extends TypeAdapter<KYC> {
  @override
  final int typeId = 1;

  @override
  KYC read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KYC()
      ..aadhar = fields[0] as String
      ..pan = fields[1] as String
      ..gst = fields[2] as String;
  }

  @override
  void write(BinaryWriter writer, KYC obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.aadhar)
      ..writeByte(1)
      ..write(obj.pan)
      ..writeByte(2)
      ..write(obj.gst);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KYCAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LandAdapter extends TypeAdapter<Land> {
  @override
  final int typeId = 2;

  @override
  Land read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Land()
      ..village = fields[0] as String
      ..syno = fields[1] as String
      ..area = fields[2] as double
      ..crops = (fields[3] as List).cast<String>()
      ..equipments = (fields[4] as List).cast<String>();
  }

  @override
  void write(BinaryWriter writer, Land obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.village)
      ..writeByte(1)
      ..write(obj.syno)
      ..writeByte(2)
      ..write(obj.area)
      ..writeByte(3)
      ..write(obj.crops)
      ..writeByte(4)
      ..write(obj.equipments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LandAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProfileDataAdapter extends TypeAdapter<ProfileData> {
  @override
  final int typeId = 3;

  @override
  ProfileData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProfileData()
      ..id = fields[0] as String
      ..updated = fields[1] as bool
      ..address = (fields[2] as List).cast<Address>()
      ..kyc = fields[3] as KYC
      ..land = (fields[4] as List).cast<Land>();
  }

  @override
  void write(BinaryWriter writer, ProfileData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.updated)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.kyc)
      ..writeByte(4)
      ..write(obj.land);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}