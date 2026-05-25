import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/storage_service.dart';

/// Auth Provider for state management
class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;

  /// Initialize auth state from storage
  Future<void> initializeAuth() async {
    _token = StorageService.getToken();
    if (_token != null) {
      final profileLoaded = await getProfile();
      if (!profileLoaded) {
        await logout();
      }
    }
    notifyListeners();
  }

  /// Register user
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.register(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
      );

      if (result['success']) {
        final userData = result['data']['user'];
        _user = User.fromJson(userData);
        _token = result['data']['token'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.login(
        email: email,
        password: password,
      );

      if (result['success']) {
        final userData = result['data']['user'];
        _user = User.fromJson(userData);
        _token = result['data']['token'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get user profile
  Future<bool> getProfile() async {
    try {
      final result = await AuthService.getProfile();
      if (result['success']) {
        _user = User.fromJson(result['data']);
        notifyListeners();
        return true;
      }

      final message = result['message']?.toString().toLowerCase() ?? '';
      if (result['statusCode'] == 401 ||
          message.contains('invalid') ||
          message.contains('expired')) {
        await logout();
      }
      _error = result['message'];
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update profile
  Future<bool> updateProfile({
    required String fullName,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.updateProfile(
        fullName: fullName,
        phone: phone,
      );

      if (result['success']) {
        _user = User.fromJson(result['data']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _token = null;
    _error = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
