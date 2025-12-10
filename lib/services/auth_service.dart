import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../config/api_config.dart';

class AuthService {
  // 🔒 CONSTANTS
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'token';

  // Helper untuk mendapatkan base URL
  String get _baseUrl => ApiConfig.baseUrl;

  // ==============================
  // REGISTER
  // ==============================
  Future<UserModel?> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password
        }),
      );

      print('Response register: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['user'] != null) {
          final user = UserModel.fromJson(data['user']);
          await _saveUserData(user);
          print('✅ Registrasi berhasil: ${user.name}');
          return user;
        }
      }

      print('❌ Gagal register: ${response.body}');
      return null;

    } catch (e) {
      print('Error register: $e');
      return null;
    }
  }

  // ==============================
  // LOGIN
  // ==============================
  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Response login: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['user'] != null) {
          final user = UserModel.fromJson(data['user']);
          await _saveUserData(user);
          return user;
        }
      }

      print('❌ Gagal login: ${response.body}');
      return null;

    } catch (e) {
      print('Error login: $e');
      return null;
    }
  }

  // ==============================
  // UPDATE PROFILE
  // ==============================
  Future<UserModel?> updateProfile({
    required String name,
    required String email,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/user/update'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
        }),
      );

      print('Response update profile: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['user'] != null) {
          final updatedUser = UserModel.fromJson({
            'id': data['user']['id'],
            'name': data['user']['name'],
            'email': data['user']['email'],
            'token': token,
          });

          await _saveUserData(updatedUser);
          return updatedUser;
        }
      }

      return null;

    } catch (e) {
      print('Error update profile: $e');
      return null;
    }
  }

  // ==============================
  // SAVE USER DATA
  // ==============================
  Future<void> _saveUserData(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final map = {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'token': user.token,
      };

      await prefs.setString(_userKey, jsonEncode(map));
      await prefs.setString(_tokenKey, user.token);
      print('✅ Data user tersimpan');

    } catch (e) {
      print('Error save user: $e');
    }
  }

  // ==============================
  // GET USER DATA
  // ==============================
  Future<UserModel?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_userKey);

      if (jsonString == null) return null;

      return UserModel.fromJson(jsonDecode(jsonString));

    } catch (e) {
      print('Error get user: $e');
      return null;
    }
  }

  // ==============================
  // CHANGE PASSWORD
  // ==============================
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/user/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengubah password',
      };

    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ==============================
  // LOGOUT
  // ==============================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
  }

  // ==============================
  // CEK LOGIN
  // ==============================
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  // ==============================
  // GET TOKEN
  // ==============================
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}