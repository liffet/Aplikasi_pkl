import 'category_model.dart';
import 'floor_model.dart';
import 'room_model.dart';
import 'building_model.dart';

class ItemModel {
  final int id;
  final int? categoryId;
  final int? roomId;
  final int? buildingId;

  final String code;
  final String name;
  final String installDate;
  final String replacementDate;
  final String? photo;

  final CategoryModel? category;
  final RoomModel? room;
  final Floor? floor;
  final Building? building;

  ItemModel({
    required this.id,
    this.categoryId,
    this.roomId,
    this.buildingId,
    required this.code,
    required this.name,
    this.category,
    required this.installDate,
    required this.replacementDate,
    this.photo,
    this.room,
    this.floor,
    this.building,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    String parseString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    final roomJson = json['room'] as Map<String, dynamic>?;
    final floorJson = json['floor'] as Map<String, dynamic>?;
    final buildingJson = json['building'] as Map<String, dynamic>?;

    return ItemModel(
      id: parseInt(json['id']) ?? 0,
      categoryId: parseInt(json['category_id']),
      roomId: parseInt(roomJson?['id']),
      buildingId: parseInt(buildingJson?['id']),

      code: parseString(json['code']),
      name: parseString(json['name']),

      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,

      installDate: parseString(json['install_date']),
      replacementDate: parseString(json['replacement_date']),
      photo: json['photo']?.toString(),

      room: roomJson != null ? RoomModel.fromJson(roomJson) : null,
      floor: floorJson != null ? Floor.fromJson(floorJson) : null,
      building: buildingJson != null ? Building.fromJson(buildingJson) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'room_id': roomId,
      'building_id': buildingId,
      'code': code,
      'name': name,
      'install_date': installDate,
      'replacement_date': replacementDate,
      'photo': photo,
      'category': category?.toJson(),
      'room': room?.toJson(),
      'floor': floor?.toJson(),
      'building': building?.toJson(),
    };
  }
}
