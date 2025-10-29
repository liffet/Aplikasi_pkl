class FloorModel {
  final int id;
  final String name;

  FloorModel({
    required this.id,
    required this.name,
  });

  factory FloorModel.fromJson(Map<String, dynamic> json) {
    return FloorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Tanpa Nama',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
