// ==========================
// Model DamageReport (FINAL)
// ==========================
class DamageReport {
  final int id;
  final int? itemId;
  final String reason;
  final String status;

  final String? itemCode;
  final String? itemName;
  final String? categoryName;
  final String? roomName;
  final String? buildingName;
  final String? floorName;

  final String? photo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DamageReport({
    required this.id,
    this.itemId,
    required this.reason,
    required this.status,
    this.itemCode,
    this.itemName,
    this.categoryName,
    this.roomName,
    this.buildingName,
    this.floorName,
    this.photo,
    this.createdAt,
    this.updatedAt,
  });

  // ==========================
  // Factory from JSON (API)
  // ==========================
  factory DamageReport.fromJson(Map<String, dynamic> json) {
    String? parseString(dynamic value) {
      if (value == null) return null;
      return value.toString();
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return DamageReport(
      id: json['id'] ?? 0,
      itemId: json['item_id'],
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',

      itemCode: parseString(json['item_code']),
      itemName: parseString(json['item_name']),
      categoryName: parseString(json['category']),
      roomName: parseString(json['room']),
      buildingName: parseString(json['building']),
      floorName: parseString(json['floor']),

      photo: parseString(json['photo']),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  // ==========================
  // To JSON (POST / PUT)
  // ==========================
  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'reason': reason,
      'status': status,
    };
  }

  // ==========================
  // Helper Status (UI)
  // ==========================
  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'accepted':
        return 'Diterima';
      case 'rejected':
        return 'Ditolak';
      case 'in_progress':
        return 'Diproses';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }

  bool get isFinished =>
      status == 'completed' || status == 'rejected';
}
