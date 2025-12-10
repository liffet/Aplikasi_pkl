import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/building_model.dart';
import '../models/floor_model.dart';
import '../config/api_config.dart';

class BuildingService {
  // ✅ Gunakan ApiConfig.baseUrl (bukan finalBaseUrl)
  String get _baseUrl => ApiConfig.baseUrl;

  // ==================================================
  // 1️⃣ GET Semua Building
  // ==================================================
  Future<List<Building>> getBuildings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login dulu.');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/buildings'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response Buildings: ${response.body}');

      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        if (body['success'] == true && body['data'] != null) {
          final List<dynamic> data = body['data'];
          return data.map((e) => Building.fromJson(e)).toList();
        } else {
          throw Exception('Data building tidak ditemukan');
        }
      } else {
        throw Exception(
          'Gagal memuat daftar building (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error mengambil data building: $e');
    }
  }

  // ==================================================
  // 2️⃣ GET Floors by Building ID
  //     /api/buildings/{id}/floors
  // ==================================================
  Future<List<FloorModel>> getFloorsByBuilding(int buildingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login dulu.');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/buildings/$buildingId/floors'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response Floors by Building: ${response.body}');

      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        if (body['success'] == true && body['floors'] != null) {
          final List<dynamic> data = body['floors'];
          return data.map((e) => FloorModel.fromJson(e)).toList();
        } else {
          throw Exception('Data lantai tidak ada');
        }
      } else {
        throw Exception(
          'Gagal memuat lantai untuk building ID $buildingId (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error mengambil data lantai: $e');
    }
  }
}