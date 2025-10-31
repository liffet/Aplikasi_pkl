import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  // ✅ CONSTANTS untuk key SharedPreferences
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'token';

  // ==============================
  // REGISTER
  // ==============================
  Future<UserModel?> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      print('Response register: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['user'] != null) {
          final user = UserModel.fromJson(data['user']);
          await _saveUserData(user);
          print('✅ Registrasi berhasil. User disimpan: ${user.name}');
          return user;
        } else {
          print('⚠️ Tidak ada data user dalam response');
          return null;
        }
      } else {
        print('❌ Gagal register: ${response.body}');
        return null;
      }
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
        Uri.parse('$baseUrl/login'),
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
          print('✅ Login berhasil. User: ${user.name}');
          return user;
        } else {
          print('⚠️ Tidak ada data user dalam response login');
          return null;
        }
      } else {
        print('❌ Gagal login: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error login: $e');
      return null;
    }
  }

  // ==============================
  // UPDATE PROFILE (FIXED & CONSISTENT)
  // ==============================
  Future<UserModel?> updateProfile({
    required String name,
    required String email,
    required String token,
  }) async {
    try {
      print('🔑 Token yang digunakan untuk update: $token');
      print('📧 Email baru: $email');
      print('👤 Nama baru: $name');

      final response = await http.post(
        Uri.parse('$baseUrl/user/update'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name, 'email': email}),
      );

      print('📊 Status Code: ${response.statusCode}');
      print('📝 Response update profile: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['user'] != null) {
          final updatedUserData = {
            'id': data['user']['id'],
            'name': data['user']['name'],
            'email': data['user']['email'],
            'token': token,
          };
          
          final updatedUser = UserModel.fromJson(updatedUserData);
          await _saveUserData(updatedUser);
          print('✅ Profil diperbarui: ${updatedUser.name}');
          return updatedUser;
        } else {
          print('⚠️ Tidak ada data user dalam response update');
        }
      } else if (response.statusCode == 401) {
        print('❌ Token tidak valid atau expired. Silakan login ulang.');
      } else {
        print('❌ Gagal update profil: ${response.body}');
      }

      return null;
    } catch (e) {
      print('💥 Error update profile: $e');
      return null;
    }
  }

  // ==============================
  // PRIVATE METHOD: SIMPAN DATA USER (CONSISTENT)
  // ==============================
  Future<void> _saveUserData(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'token': user.token,
      };
      
      await prefs.setString(_userKey, jsonEncode(userData));
      await prefs.setString(_tokenKey, user.token);
      
      print('✅ Data user tersimpan: ${user.name}');
    } catch (e) {
      print('❌ Error saving user data: $e');
    }
  }

  // ==============================
  // GET USER DATA (CONSISTENT)
  // ==============================
  Future<UserModel?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_userKey);
      
      if (jsonString == null) {
        print('❌ Tidak ada data user di SharedPreferences');
        return null;
      }
      
      final userData = jsonDecode(jsonString);
      final user = UserModel.fromJson(userData);
      
      print('✅ Data user diambil: ${user.name}');
      return user;
    } catch (e) {
      print('❌ Error getting user data: $e');
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
        Uri.parse('$baseUrl/user/change-password'),
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Password berhasil diubah');

        if (data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, data['token']);
          print('✅ Token diperbarui setelah ganti password');
        }

        return {'success': true, 'message': data['message'] ?? 'Password berhasil diubah'};
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        String errorMessage = 'Gagal mengubah password';

        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          errorMessage = errors.values.first[0];
        } else if (data['message'] != null) {
          errorMessage = data['message'];
        }

        return {'success': false, 'message': errorMessage};
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Password lama salah'};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Gagal mengubah password'};
      }
    } catch (e) {
      print('💥 Error change password: $e');
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // ==============================
  // LOGOUT
  // ==============================
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_tokenKey);
      print('✅ Logout berhasil, data user & token dihapus');
    } catch (e) {
      print('❌ Error during logout: $e');
    }
  }

  // ==============================
  // CEK LOGIN STATUS
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