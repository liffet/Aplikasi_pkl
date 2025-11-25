class FloorModel {
  final int id;
  final String name;
  final int buildingId; // ← tambahkan

  FloorModel({
    required this.id,
    required this.name,
    required this.buildingId,
  });

  factory FloorModel.fromJson(Map<String, dynamic> json) {
    return FloorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Tanpa Nama',
      buildingId: json['building_id'] ?? 0, // ← tambahkan
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'building_id': buildingId, // ← tambahkan
    };
  }
}
