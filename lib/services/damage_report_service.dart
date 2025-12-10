import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import '../models/damage_report_model.dart';
import '../config/api_config.dart'; // ⬅️ Tambahkan ini

class DamageReportService {
  // Ganti hardcode dengan ApiConfig
  final String baseUrl = '${ApiConfig.baseUrl}/damage-reports';

  /// 🔹 [1] Kirim laporan untuk WEB (pakai Uint8List)
  Future<bool> createReportWeb(
    DamageReport report,
    String token,
    Uint8List webImageBytes,
    String fileName,
  ) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Field teks
      request.fields['item_id'] = report.itemId.toString();
      request.fields['reason'] = report.reason;

      // File dari bytes
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          webImageBytes,
          filename: fileName,
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        print('✅ Laporan (WEB) berhasil dibuat: ${response.body}');
        return true;
      } else {
        print('❌ Gagal membuat laporan WEB (${response.statusCode}): ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error createReportWeb: $e');
      return false;
    }
  }

  /// 🔹 [2] Kirim laporan untuk MOBILE (pakai File)
  Future<bool> createReportMobile(
    DamageReport report,
    String token,
    File photo,
  ) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['item_id'] = report.itemId.toString();
      request.fields['reason'] = report.reason;

      // File dari path
      request.files.add(
        await http.MultipartFile.fromPath('photo', photo.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        print('✅ Laporan (MOBILE) berhasil dibuat: ${response.body}');
        return true;
      } else {
        print('❌ Gagal membuat laporan MOBILE (${response.statusCode}): ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error createReportMobile: $e');
      return false;
    }
  }

  /// 🔹 [3] Ambil semua laporan
  Future<List<DamageReport>> getReports(String token) async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);

        if (body.containsKey('data') && body['data'] is List) {
          final List<dynamic> reportsJson = body['data'];
          return reportsJson.map((json) => DamageReport.fromJson(json)).toList();
        } else {
          print('⚠️ Struktur respons tidak sesuai: ${response.body}');
          return [];
        }
      } else {
        print('❌ Gagal mengambil laporan (${response.statusCode}): ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Error getReports: $e');
      return [];
    }
  }
}
