import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import '../models/damage_report_model.dart';
import '../config/api_config.dart';

class DamageReportService {
  final String baseUrl = '${ApiConfig.baseUrl}/damage-reports';

  // ==========================
  // [1] CREATE REPORT - WEB
  // ==========================
  Future<bool> createReportWeb(
    DamageReport report,
    String token,
    Uint8List webImageBytes,
    String fileName,
  ) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (report.itemId != null) {
        request.fields['item_id'] = report.itemId.toString();
      }
      request.fields['reason'] = report.reason;

      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          webImageBytes,
          filename: fileName,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 201;
    } catch (e) {
      print('❌ createReportWeb error: $e');
      return false;
    }
  }

  // ==========================
  // [2] CREATE REPORT - MOBILE
  // ==========================
  Future<bool> createReportMobile(
    DamageReport report,
    String token,
    File photo,
  ) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (report.itemId != null) {
        request.fields['item_id'] = report.itemId.toString();
      }
      request.fields['reason'] = report.reason;

      request.files.add(
        await http.MultipartFile.fromPath('photo', photo.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 201;
    } catch (e) {
      print('❌ createReportMobile error: $e');
      return false;
    }
  }

  // ==========================
  // [3] GET ALL REPORTS
  // ==========================
  Future<List<DamageReport>> getReports(String token) async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) return [];

      final body = jsonDecode(response.body);

      if (body['data'] is List) {
        return (body['data'] as List)
            .map((e) => DamageReport.fromJson(e))
            .toList();
      }

      return [];
    } catch (e) {
      print('❌ getReports error: $e');
      return [];
    }
  }

  // ==========================
  // [4] GET DETAIL REPORT
  // ==========================
  Future<DamageReport?> getReportDetail(
    int id,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body);
      return DamageReport.fromJson(body['data']);
    } catch (e) {
      print('❌ getReportDetail error: $e');
      return null;
    }
  }

  // ==========================
  // [5] UPDATE STATUS (ADMIN)
  // ==========================
  Future<bool> updateStatus(
    int reportId,
    String status,
    String token,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$reportId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': status,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ updateStatus error: $e');
      return false;
    }
  }

  // ==========================
  // [6] DELETE REPORT (ADMIN)
  // ==========================
  Future<bool> deleteReport(
    int id,
    String token,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ deleteReport error: $e');
      return false;
    }
  }
}
