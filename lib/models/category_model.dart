class CategoryModel {
  final int id;
  final String name;

  CategoryModel({
    required this.id,
    required this.name,
  });

  /// 🔹 Konversi dari JSON ke model
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  /// 🔹 Konversi dari model ke JSON (kalau mau kirim ke API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
