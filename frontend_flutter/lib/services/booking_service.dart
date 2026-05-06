import 'package:dio/dio.dart';
import '../utils/constants.dart';
import 'http_service.dart';

/// Booking Service
class BookingService {
  /// Create booking
  static Future<Map<String, dynamic>> createBooking({
    required String serviceId,
    required String bookingDate,
    required String bookingTime,
    required String address,
    required String city,
    String? notes,
  }) async {
    try {
      final response = await HttpService.post(
        ApiEndpoints.createBooking,
        data: {
          'service_id': serviceId,
          'booking_date': bookingDate,
          'booking_time': bookingTime,
          'address': address,
          'city': city,
          'notes': notes,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data;
        if (data['success']) {
          return {'success': true, 'data': data['data']};
        }
      }
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to create booking'
      };
    } on DioException catch (e) {
      return {'success': false, 'message': e.message ?? 'Network error'};
    }
  }

  /// Get my bookings
  static Future<Map<String, dynamic>> getMyBookings() async {
    try {
      final response = await HttpService.get(ApiEndpoints.myBookings);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success']) {
          return {'success': true, 'data': data['data']};
        }
      }
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to fetch bookings'
      };
    } on DioException catch (e) {
      return {'success': false, 'message': e.message ?? 'Network error'};
    }
  }

  /// Get booking by ID
  static Future<Map<String, dynamic>> getBookingById(String id) async {
    try {
      final response = await HttpService.get(ApiEndpoints.bookingDetail(id));

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success']) {
          return {'success': true, 'data': data['data']};
        }
      }
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to fetch booking'
      };
    } on DioException catch (e) {
      return {'success': false, 'message': e.message ?? 'Network error'};
    }
  }

  /// Cancel booking
  static Future<Map<String, dynamic>> cancelBooking(String id) async {
    try {
      final response =
          await HttpService.put(ApiEndpoints.cancelBooking(id), data: {});

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success']) {
          return {'success': true, 'data': data['data']};
        }
      }
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to cancel booking'
      };
    } on DioException catch (e) {
      return {'success': false, 'message': e.message ?? 'Network error'};
    }
  }
}
