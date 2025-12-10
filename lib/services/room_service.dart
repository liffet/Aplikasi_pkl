import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/room_model.dart';
import '../config/api_config.dart';

class RoomService {
  // ✅ Gunakan ApiConfig.baseUrl (bukan finalBaseUrl)
  String get _baseUrl => ApiConfig.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<RoomModel>> getRooms() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login ulang.');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/rooms'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code (Rooms): ${response.statusCode}');
      print('Response Body (Rooms): ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['success'] == true) {
          final List data = decoded['data'];
          return data.map((json) => RoomModel.fromJson(json)).toList();
        } else {
          throw Exception('Respon tidak valid dari server');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Token tidak valid atau sudah kedaluwarsa.');
      } else {
        throw Exception('Gagal memuat data ruangan (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memuat data ruangan: $e');
    }
  }

  Future<RoomModel> getRoom(int id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login ulang.');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/rooms/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return RoomModel.fromJson(decoded['data']);
      } else {
        throw Exception('Gagal memuat detail ruangan (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memuat detail ruangan: $e');
    }
  }
}