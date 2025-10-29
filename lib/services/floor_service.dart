import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/floor_model.dart';

class FloorService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<List<FloorModel>> getFloors() async {
    try {
      // 🔹 Ambil token dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login dulu.');
      }

      // 🔹 Kirim request GET dengan Authorization header
      final response = await http.get(
        Uri.parse('$baseUrl/floors'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // 🔥 penting!
        },
      );

      print('Response Floors: ${response.body}');

      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        if (body['success'] == true && body['data'] != null) {
          final List<dynamic> data = body['data'];
          return data.map((e) => FloorModel.fromJson(e)).toList();
        } else {
          throw Exception('Data lantai kosong atau format salah');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Token tidak valid atau sudah kedaluwarsa.');
      } else {
        throw Exception('Gagal memuat data lantai (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error mengambil data lantai: $e');
    }
  }
}
