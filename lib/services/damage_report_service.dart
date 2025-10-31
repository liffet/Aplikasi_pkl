import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/damage_report_model.dart';

class DamageReportService {
  // ⚠️ Ganti IP dengan IP LAN kamu (jika test di emulator)
  // contoh: 'http://10.0.2.2:8000/api/damage-reports' untuk Android emulator
  final String baseUrl = 'http://127.0.0.1:8000/api/damage-reports';
  
  /// 🔹 Buat laporan baru
  Future<bool> createReport(DamageReport report, String token) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(report.toJson()),
      );

      if (response.statusCode == 201) {
        print('✅ Laporan berhasil dibuat: ${response.body}');
        return true;
      } else {
        print(
            '❌ Gagal membuat laporan (${response.statusCode}): ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error createReport: $e');
      return false;
    }
  }

  /// 🔹 Ambil semua laporan user (atau semua jika admin)
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

        // Pastikan struktur sesuai: { message: ..., data: [...] }
        if (body.containsKey('data') && body['data'] is List) {
          final List<dynamic> reportsJson = body['data'];
          return reportsJson
              .map((json) => DamageReport.fromJson(json))
              .toList();
        } else {
          print('⚠️ Struktur respons tidak sesuai: ${response.body}');
          return [];
        }
      } else {
        print(
            '❌ Gagal mengambil laporan (${response.statusCode}): ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Error getReports: $e');
      return [];
    }
  }
}
