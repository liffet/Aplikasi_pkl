// ==========================
// Model DamageReport (Fix)
// ==========================
class DamageReport {
  final int id;
  final int itemId;
  final String reason;
  final String status;
  final String? itemCode; // kode barang
  final String? itemName; // nama barang
  final String? roomName; // nama ruangan
  final String? buildingName; // nama gedung
  final String? photo; // foto laporan
  final DateTime? createdAt;

  DamageReport({
    required this.id,
    required this.itemId,
    required this.reason,
    required this.status,
    this.itemCode,
    this.itemName,
    this.roomName,
    this.buildingName,
    this.photo,
    this.createdAt,
  });

  factory DamageReport.fromJson(Map<String, dynamic> json) {
    String? parseString(dynamic value) {
      if (value == null) return null;
      return value.toString();
    }

    String? parseNestedName(dynamic value) {
      if (value == null) return null;
      if (value is Map && value.containsKey('name')) {
        return parseString(value['name']);
      } else if (value is String) {
        return value;
      }
      return null;
    }

    return DamageReport(
      id: json['id'] ?? 0,
      itemId: json['item_id'] ?? 0,
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
      itemCode: parseString(json['item_code']),
      itemName: parseString(json['item_name']),
      roomName: parseNestedName(json['room']),
      buildingName: parseNestedName(json['building']),
      photo: parseString(json['photo']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'reason': reason,
      'status': status,
      'photo': photo,
    };
  }
}
