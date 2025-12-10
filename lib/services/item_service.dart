import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart'; // ⬅️ tambah ini

class ItemService {
  // Ganti baseUrl hardcode menjadi ApiConfig
  final String baseUrl = ApiConfig.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<ItemModel>> getItems() async {
    try {
      final token = await _getToken();
      
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login ulang.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/items'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((e) => ItemModel.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Sesi Anda telah berakhir. Silakan login ulang.');
      } else {
        throw Exception('Gagal memuat item (${response.statusCode})');
      }
    } catch (e) {
      print('Error getItems: $e');
      rethrow;
    }
  }
}
