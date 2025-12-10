class Building {
  final int? id; // nullable
  final String name;
  final int totalFloors;
  final List<Floor>? floors;

  Building({
    this.id,
    required this.name,
    required this.totalFloors,
    this.floors,
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    final floorsJson = json['floors'] as List<dynamic>?;

    return Building(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name']?.toString() ?? '',
      totalFloors: json['total_floors'] != null
          ? int.tryParse(json['total_floors'].toString()) ?? 0
          : 0,
      floors: floorsJson != null
          ? floorsJson
              .map((f) => Floor.fromJson(f as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'total_floors': totalFloors,
      'floors': floors?.map((f) => f.toJson()).toList(),
    };
  }
}

class Floor {
  final int? id; // nullable
  final String name;
  final int? buildingId; // nullable

  Floor({
    this.id,
    required this.name,
    this.buildingId,
  });

  factory Floor.fromJson(Map<String, dynamic> json) {
    return Floor(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name']?.toString() ?? '',
      buildingId: json['building_id'] != null
          ? int.tryParse(json['building_id'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'building_id': buildingId,
    };
  }
}
