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
      final fresh = await _authService.getUserData();
      _user = fresh;
      print('🔄 UserProvider: User loaded - ${_user?.name}');
    } catch (e) {
      _user = null;
      print('❌ UserProvider: loadUser error: $e');
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
      final result = await _authService.login(email, password);
      if (result != null) {
        _user = result;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ UserProvider: login error: $e');
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
      final result = await _authService.register(name, email, password);
      if (result != null) {
        _user = result;
        return true;
      }
      return false;
    } catch (e) {
      print('❌ UserProvider: register error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile dengan force refresh
  Future<bool> updateProfile(String name, String email) async {
    if (_user == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final token = await _authService.getToken();
      if (token == null) return false;
      final updated = await _authService.updateProfile(token: token, name: name, email: email);
      if (updated != null) {
        _user = updated;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ UserProvider: updateProfile error: $e');
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
      print('❌ UserProvider: Logout error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear user data
  void clearUser() {
    _user = null;
    notifyListeners();
  }

  // Force refresh user data
  Future<void> forceRefreshUser() async {
    await loadUser();
  }
}
