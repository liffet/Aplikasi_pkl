class Building {
  final int id;
  final String name;
  final int totalFloors;
  final List<Floor>? floors;

  Building({
    required this.id,
    required this.name,
    required this.totalFloors,
    this.floors,
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'],
      name: json['name'],
      totalFloors: json['total_floors'],
      floors: json['floors'] != null
          ? List<Floor>.from(
              json['floors'].map((f) => Floor.fromJson(f)),
            )
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
  final int id;
  final String name;
  final int buildingId;

  Floor({
    required this.id,
    required this.name,
    required this.buildingId,
  });

  factory Floor.fromJson(Map<String, dynamic> json) {
    return Floor(
      id: json['id'],
      name: json['name'],
      buildingId: json['building_id'],
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
