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
    required String startTime,
    required String endTime,
    required double durationHours,
    required String address,
    required String city,
    String? notes,
    bool isCustom = false,
    String? propertyType,
    int roomCount = 0,
    int bathroomsCount = 0,
    int kitchensCount = 0,
    String cleaningType = 'normal',
    String? extras,
    double discountAmount = 0.0,
    String? promoCode,
    bool redeemLoyalty = false,
    bool saveAddress = false,
    String? addressLabel,
  }) async {
    try {
      final response = await HttpService.post(
        ApiEndpoints.createBooking,
        data: {
          'service_id': serviceId,
          'booking_date': bookingDate,
          'booking_time': bookingTime,
          'start_time': startTime,
          'end_time': endTime,
          'duration_hours': durationHours,
          'address': address,
          'city': city,
          'notes': notes,
          'is_custom': isCustom,
          'property_type': propertyType,
          'room_count': roomCount,
          'bathrooms_count': bathroomsCount,
          'kitchens_count': kitchensCount,
          'cleaning_type': cleaningType,
          'extras': extras,
          'discount_amount': discountAmount,
          'promo_code': promoCode,
          'redeem_loyalty': redeemLoyalty,
          'save_address': saveAddress,
          'address_label': addressLabel,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
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
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error'
      };
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
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error'
      };
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
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error'
      };
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
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error'
      };
    }
  }

  /// Complete booking
  static Future<Map<String, dynamic>> completeBooking(String id) async {
    try {
      final response =
          await HttpService.put(ApiEndpoints.completeBooking(id), data: {});

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success']) {
          return {'success': true, 'data': data['data']};
        }
      }
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to complete booking'
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error'
      };
    }
  }

  /// Validate promo code
  static Future<Map<String, dynamic>> validatePromo({
    required String code,
    required String cleaningType,
    required String extras,
    required double subtotal,
  }) async {
    try {
      final response = await HttpService.post(
        ApiEndpoints.validatePromo,
        data: {
          'code': code,
          'cleaning_type': cleaningType,
          'extras': extras,
          'subtotal': subtotal,
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
        'message': response.data['message'] ?? 'Invalid promo code'
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error'
      };
    }
  }
}
