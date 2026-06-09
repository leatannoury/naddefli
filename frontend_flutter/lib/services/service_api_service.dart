// =============================================================================
// NADDEFLI — service_api_service.dart
// Layer: Flutter — Service
// Purpose: Fetches service catalog from backend.
// Connects to: GET /api/services
// =============================================================================

import 'package:dio/dio.dart';
import '../utils/constants.dart';
import 'http_service.dart';

/// Service API Service
class ServiceApiService {
  /// Get all services
  static Future<Map<String, dynamic>> getServices() async {
    try {
      final response = await HttpService.get(ApiEndpoints.services);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success']) {
          return {'success': true, 'data': data['data']};
        }
      }
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to fetch services'
      };
    } on DioException catch (e) {
      return {'success': false, 'message': e.message ?? 'Network error'};
    }
  }

  /// Get service by ID
  static Future<Map<String, dynamic>> getServiceById(String id) async {
    try {
      final response =
          await HttpService.get(ApiEndpoints.serviceDetail(id));

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success']) {
          return {'success': true, 'data': data['data']};
        }
      }
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to fetch service'
      };
    } on DioException catch (e) {
      return {'success': false, 'message': e.message ?? 'Network error'};
    }
  }
}
