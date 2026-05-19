import 'package:dio/dio.dart';
import '../utils/constants.dart';
import 'http_service.dart';

/// Address Service
class AddressService {
  /// Fetch all saved addresses
  static Future<Map<String, dynamic>> fetchAddresses() async {
    try {
      final response = await HttpService.get(ApiEndpoints.addresses);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success']) {
          return {'success': true, 'data': data['data']};
        }
      }
      return {'success': false, 'message': 'Failed to fetch addresses'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error'
      };
    }
  }

  /// Add a new address
  static Future<Map<String, dynamic>> addAddress({
    required String label,
    required String address,
    required String city,
    String? building,
    String? floor,
    String? notes,
  }) async {
    try {
      final response = await HttpService.post(
        ApiEndpoints.addresses,
        data: {
          'label': label,
          'address': address,
          'city': city,
          'building': building,
          'floor': floor,
          'notes': notes,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        if (data['success']) {
          return {'success': true, 'data': data['data']};
        }
      }
      return {'success': false, 'message': 'Failed to save address'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error'
      };
    }
  }

  /// Update an existing address
  static Future<Map<String, dynamic>> updateAddress({
    required String id,
    required String label,
    required String address,
    required String city,
    String? building,
    String? floor,
    String? notes,
  }) async {
    try {
      final response = await HttpService.put(
        ApiEndpoints.updateAddress(id),
        data: {
          'label': label,
          'address': address,
          'city': city,
          'building': building,
          'floor': floor,
          'notes': notes,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success']) {
          return {'success': true, 'data': data['data']};
        }
      }
      return {'success': false, 'message': 'Failed to update address'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error'
      };
    }
  }

  /// Delete an address
  static Future<Map<String, dynamic>> deleteAddress(String id) async {
    try {
      final response = await HttpService.delete(ApiEndpoints.deleteAddress(id));
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success']) {
          return {'success': true};
        }
      }
      return {'success': false, 'message': 'Failed to delete address'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error'
      };
    }
  }
}
