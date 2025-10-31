class DamageReport {
  final int id;
  final int itemId;
  final String reason;
  final String status;
  final String? itemCode; // kode barang
  final String? itemName; // nama barang
  final DateTime? createdAt;

  DamageReport({
    required this.id,
    required this.itemId,
    required this.reason,
    required this.status,
    this.itemCode,
    this.itemName,
    this.createdAt,
  });

  factory DamageReport.fromJson(Map<String, dynamic> json) {
    return DamageReport(
      id: json['id'] ?? 0,
      itemId: json['item_id'] ?? 0,
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
      itemCode: json['item_code'], // ambil dari API
      itemName: json['item_name'], // ambil dari API
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
    };
  }
}
