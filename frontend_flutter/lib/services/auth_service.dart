// =============================================================================
// NADDEFLI — auth_service.dart
// Layer: Flutter — Service
// Purpose: Low-level API calls for register, login, get/update profile.
// Connects to: HttpService → /api/auth/*
// =============================================================================

import 'package:dio/dio.dart';
import '../utils/constants.dart';
import '../utils/storage_service.dart';
import 'http_service.dart';

/// Auth Service
class AuthService {
  /// Register user
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await HttpService.post(
        ApiEndpoints.register,
        data: {
          'full_name': fullName,
          'email': email,
          'password': password,
          'phone': phone,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data;
        if (data['success'] && data['data'] != null) {
          final token = data['data']['token'];
          await StorageService.saveToken(token);
          return {'success': true, 'data': data['data']};
        }
      }
      return {
        'success': false,
        'message': response.data['message'] ?? 'Registration failed'
      };
    } on DioException catch (e) {
      return {'success': false, 'message': e.message ?? 'Network error'};
    }
  }

  /// Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await HttpService.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] && data['data'] != null) {
          final token = data['data']['token'];
          final user = data['data']['user'];
          
          await StorageService.saveToken(token);
          await StorageService.saveUserId(user['id'].toString());
          await StorageService.saveUserRole(user['role'].toString());
          
          return {'success': true, 'data': data['data']};
        }
      }
      return {
        'success': false,
        'message': response.data['message'] ?? 'Login failed'
      };
    } on DioException catch (e) {
      return {'success': false, 'message': e.message ?? 'Network error'};
    }
  }

  /// Get user profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await HttpService.get(ApiEndpoints.profile);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success']) {
          return {'success': true, 'data': data['data']};
        }
      }
      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': response.data['message'] ?? 'Failed to fetch profile'
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? e.message ?? 'Network error',
        'statusCode': e.response?.statusCode,
      };
    }
  }

  /// Update profile
  static Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    String? phone,
  }) async {
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
          return {'success': true, 'data': data['data']};
        }
      }
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to update profile'
      };
    } on DioException catch (e) {
      return {'success': false, 'message': e.message ?? 'Network error'};
    }
  }

  /// Logout
  static Future<void> logout() async {
    await StorageService.clearAll();
  }
}
