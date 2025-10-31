import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  final AuthService _authService = AuthService();

  // Load user data saat aplikasi dimulai
  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final savedUser = await _authService.getUserData();
      _user = savedUser;
    } catch (e) {
      print('Error loading user: $e');
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login user
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Bersihkan data lama sebelum login baru
      await _authService.logout();

      final loggedInUser = await _authService.login(email, password);
      if (loggedInUser != null) {
        _user = loggedInUser;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register user
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final registeredUser = await _authService.register(name, email, password);
      if (registeredUser != null) {
        _user = registeredUser;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Register error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile
  Future<bool> updateProfile(String name, String email) async {
    if (_user == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final token = _user!.token;
      final updatedUser = await _authService.updateProfile(
        name: name,
        email: email,
        token: token,
      );

      if (updatedUser != null) {
        _user = updatedUser;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _user = null;
      notifyListeners();
    } catch (e) {
      print('Logout error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear user data (untuk force logout)
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
