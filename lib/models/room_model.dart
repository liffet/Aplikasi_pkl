import 'floor_model.dart';

class RoomModel {
  final int id;
  final String name;
  final int floorId;
  final FloorModel? floor;

  RoomModel({
    required this.id,
    required this.name,
    required this.floorId,
    this.floor,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '-',
      floorId: json['floor_id'] ?? 0,
      floor: json['floor'] != null
          ? FloorModel.fromJson(json['floor'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'floor_id': floorId,
      'floor': floor?.toJson(), // ✅ pastikan FloorModel punya toJson()
    };
  }
}
