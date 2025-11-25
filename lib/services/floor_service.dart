import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/floor_model.dart';

class FloorService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<List<FloorModel>> getFloors(int buildingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login dulu.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/floors?building_id=$buildingId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response Floors: ${response.body}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        if (body['success'] == true && body['data'] != null) {
          final List<dynamic> data = body['data'];
          return data.map((e) => FloorModel.fromJson(e)).toList();
        } else {
          return []; // 🟦 Kembalikan list kosong jika tidak ada lantai
        }
      } else {
        throw Exception(body['message'] ?? 'Gagal memuat lantai');
      }
    } catch (e) {
      throw Exception('Error mengambil data lantai: $e');
    }
  }
}
