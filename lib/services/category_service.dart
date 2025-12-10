import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category_model.dart';
import '../config/api_config.dart'; // ⬅️ Tambahkan ini

class CategoryService {
  // Ganti hardcode dengan ApiConfig
  final String baseUrl = ApiConfig.baseUrl;

  /// 🔹 Ambil token dari SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// 🔹 Ambil semua kategori
  Future<List<CategoryModel>> getCategories() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token tidak ditemukan. Silakan login ulang.');

      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => CategoryModel.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Sesi Anda telah berakhir. Silakan login ulang.');
      } else {
        throw Exception('Gagal memuat kategori (${response.statusCode})');
      }
    } catch (e) {
      print('Error getCategories: $e');
      rethrow;
    }
  }

  /// 🔹 Tambah kategori baru
  Future<void> addCategory(String name) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token tidak ditemukan.');

      final response = await http.post(
        Uri.parse('$baseUrl/categories'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': name}),
      );

      if (response.statusCode != 201) {
        throw Exception('Gagal menambah kategori (${response.statusCode})');
      }
    } catch (e) {
      print('Error addCategory: $e');
      rethrow;
    }
  }

  /// 🔹 Perbarui kategori
  Future<void> updateCategory(int id, String name) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token tidak ditemukan.');

      final response = await http.put(
        Uri.parse('$baseUrl/categories/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': name}),
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal memperbarui kategori (${response.statusCode})');
      }
    } catch (e) {
      print('Error updateCategory: $e');
      rethrow;
    }
  }

  /// 🔹 Hapus kategori
  Future<void> deleteCategory(int id) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token tidak ditemukan.');

      final response = await http.delete(
        Uri.parse('$baseUrl/categories/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus kategori (${response.statusCode})');
      }
    } catch (e) {
      print('Error deleteCategory: $e');
      rethrow;
    }
  }
}
