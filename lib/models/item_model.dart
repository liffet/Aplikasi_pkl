import 'package:flutter_application_1/models/floor_model.dart';

import 'room_model.dart';

class ItemModel {
  final int id;
  final int? categoryId;
  final int? roomId;
  final String code;
  final String name;
  final String? category; // ubah dari CategoryModel ke String
  final String installDate;
  final String replacementDate;
  final String? photo;
  final RoomModel? room;
  final FloorModel? floor;

  ItemModel({
    required this.id,
    this.categoryId,
    this.roomId,
    required this.code,
    required this.name,
    this.category,
    required this.installDate,
    required this.replacementDate,
    this.photo,
    this.room,
    this.floor,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
  final rawPhoto = json['photo'];
  String? photoUrl;

  if (rawPhoto != null && rawPhoto.toString().isNotEmpty) {
    if (rawPhoto.toString().startsWith('http')) {
      photoUrl = rawPhoto.toString();
    } else {
      photoUrl = "http://127.0.0.1:8000/storage/items/$rawPhoto";
    }
  }

  return ItemModel(
    id: json['id'] ?? 0,
    categoryId: json['category_id'],
    // 🔹 ambil id dari objek room
    roomId: json['room']?['id'], 
    code: json['code'] ?? '',
    name: json['name'] ?? '',
    category: json['category']?.toString(),
    installDate: json['install_date'] ?? '',
    replacementDate: json['replacement_date'] ?? '',
    photo: photoUrl,
    room: json['room'] != null ? RoomModel.fromJson(json['room']) : null,
    floor: json['floor'] != null ? FloorModel.fromJson(json['floor']) : null,
  );
}


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'room_id': roomId,
      'code': code,
      'name': name,
      'category': category,
      'install_date': installDate,
      'replacement_date': replacementDate,
      'photo': photo,
      'room': room != null ? room!.toJson() : null,
      'floor': floor != null ? floor!.toJson() : null,
    };
  }
}
