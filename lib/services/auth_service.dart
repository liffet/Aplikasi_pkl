import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  final String baseUrl = 'http://127.0.0.1:8000/api'; // ubah ke IP LAN jika di emulator/device

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

          // Simpan token & user ke local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', user.token);
          await prefs.setString('user', jsonEncode(data['user']));

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

          // Simpan token & user ke local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', user.token);
          await prefs.setString('user', jsonEncode(data['user']));

          print('✅ Login berhasil. User: ${user.name}');
          print('✅ Token tersimpan: ${user.token}');
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
  // UPDATE PROFILE (FIXED)
  // ==============================
  Future<UserModel?> updateProfile({
    required String name,
    required String email,
    required String token,
  }) async {
    try {
      // Debug: Print token yang digunakan
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
          // Buat user model dengan token yang ada
          final updatedUserData = {
            'id': data['user']['id'],
            'name': data['user']['name'],
            'email': data['user']['email'],
            'token': token, // gunakan token yang ada
          };
          
          final updatedUser = UserModel.fromJson(updatedUserData);
          
          // Simpan ke SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', jsonEncode(updatedUserData));
          await prefs.setString('token', token); // pastikan token tetap tersimpan
          
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
  // CHANGE PASSWORD
  // ==============================
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
    required String token,
  }) async {
    try {
      print('🔑 Token yang digunakan untuk change password: $token');
      
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

      print('📊 Status Code: ${response.statusCode}');
      print('📝 Response change password: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Password berhasil diubah');

        // Check if new token is provided (in case backend invalidates old token)
        if (data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
          print('✅ Token diperbarui setelah ganti password');
        }

        return {'success': true, 'message': data['message'] ?? 'Password berhasil diubah'};
      } else if (response.statusCode == 422) {
        // Validation error
        final data = jsonDecode(response.body);
        String errorMessage = 'Gagal mengubah password';

        if (data['errors'] != null) {
          // Ambil error pertama
          final errors = data['errors'] as Map<String, dynamic>;
          errorMessage = errors.values.first[0];
        } else if (data['message'] != null) {
          errorMessage = data['message'];
        }

        print('⚠️ Validation error: $errorMessage');
        return {'success': false, 'message': errorMessage};
      } else if (response.statusCode == 401) {
        print('❌ Password lama salah atau token tidak valid');
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
    // Hapus data lokal untuk logout
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    print('✅ Logout berhasil, data user & token dihapus');

    // Note: Backend logout endpoint belum diimplementasi dengan benar
    // Token akan expired secara otomatis di backend
  }

  // ==============================
  // CEK LOGIN STATUS
  // ==============================
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  // ==============================
  // GET TOKEN
  // ==============================
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ==============================
  // SIMPAN DAN AMBIL DATA USER
  // ==============================
  Future<void> saveUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode({
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'token': user.token,
    }));
    print('✅ Data user tersimpan: ${user.name}');
  }

  Future<UserModel?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('user');
    if (jsonString == null) return null;
    return UserModel.fromJson(jsonDecode(jsonString));
  }
}