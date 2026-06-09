// =============================================================================
// NADDEFLI — auth_provider.dart
// Layer: Flutter — State (Provider)
// Purpose: Manages login state: user object, JWT token, loading/error. Calls auth services.
// Connects to: FirebaseAuthService, StorageService, GET /api/auth/profile
// =============================================================================

import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/firebase_auth_service.dart';
import '../services/http_service.dart';
import '../utils/constants.dart';
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

  /// Register user with Firebase + Backend
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
      final result = await FirebaseAuthService.signUpWithEmail(
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

  /// Login user with Firebase + Backend
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await FirebaseAuthService.signInWithEmail(
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

  /// Login with Google
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await FirebaseAuthService.signInWithGoogle();

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
      final response = await HttpService.get(ApiEndpoints.profile);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success']) {
          _user = User.fromJson(data['data']);
          notifyListeners();
          return true;
        }
      }

      final message = response.data['message']?.toString().toLowerCase() ?? '';
      if (response.statusCode == 401 ||
          message.contains('invalid') ||
          message.contains('expired')) {
        await logout();
      }
      _error = response.data['message'];
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
      final response = await HttpService.put(
        ApiEndpoints.profile,
        data: {
          'full_name': fullName,
          if (phone != null) 'phone': phone,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success']) {
          _user = User.fromJson(data['data']);
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
      _error = response.data['message'];
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await FirebaseAuthService.signOut();
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
