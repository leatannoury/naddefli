import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

/// Booking Provider for state management
class BookingProvider extends ChangeNotifier {
  List<Booking> _bookings = [];
  Booking? _selectedBooking;
  Booking? _lastCreatedBooking;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Booking> get bookings => _bookings;
  Booking? get selectedBooking => _selectedBooking;
  Booking? get lastCreatedBooking => _lastCreatedBooking;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Create booking
  Future<bool> createBooking({
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await BookingService.createBooking(
        serviceId: serviceId,
        bookingDate: bookingDate,
        bookingTime: bookingTime,
        startTime: startTime,
        endTime: endTime,
        durationHours: durationHours,
        address: address,
        city: city,
        notes: notes,
        isCustom: isCustom,
        propertyType: propertyType,
        roomCount: roomCount,
        bathroomsCount: bathroomsCount,
        kitchensCount: kitchensCount,
        cleaningType: cleaningType,
        extras: extras,
        discountAmount: discountAmount,
        promoCode: promoCode,
        redeemLoyalty: redeemLoyalty,
        saveAddress: saveAddress,
        addressLabel: addressLabel,
      );

      if (result['success']) {
        final createdBooking = Booking.fromJson(result['data']);
        _lastCreatedBooking = createdBooking;
        _selectedBooking = createdBooking;

        final existingIndex =
            _bookings.indexWhere((booking) => booking.id == createdBooking.id);
        if (existingIndex == -1) {
          _bookings = [createdBooking, ..._bookings];
        } else {
          _bookings[existingIndex] = createdBooking;
        }

        await fetchMyBookings();
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

  /// Fetch my bookings
  Future<void> fetchMyBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await BookingService.getMyBookings();

      if (result['success']) {
        final bookingsList = result['data'] as List;
        _bookings = bookingsList.map((b) => Booking.fromJson(b)).toList();
        _isLoading = false;
        notifyListeners();
      } else {
        _error = result['message'];
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get booking by ID
  Future<void> fetchBookingById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await BookingService.getBookingById(id);

      if (result['success']) {
        _selectedBooking = Booking.fromJson(result['data']);
        _isLoading = false;
        notifyListeners();
      } else {
        _error = result['message'];
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cancel booking
  Future<bool> cancelBooking(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await BookingService.cancelBooking(id);

      if (result['success']) {
        final updatedBooking = Booking.fromJson(result['data']);
        final index = _bookings.indexWhere((b) => b.id == id);
        if (index != -1) {
          _bookings[index] = updatedBooking;
        }
        if (_selectedBooking?.id == id) {
          _selectedBooking = updatedBooking;
        }
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

  /// Complete booking
  Future<bool> completeBooking(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await BookingService.completeBooking(id);

      if (result['success']) {
        final updatedBooking = Booking.fromJson(result['data']);
        final index = _bookings.indexWhere((b) => b.id == id);
        if (index != -1) {
          _bookings[index] = updatedBooking;
        }
        if (_selectedBooking?.id == id) {
          _selectedBooking = updatedBooking;
        }
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

  /// Validate promo code
  Future<Map<String, dynamic>> validatePromoCode({
    required String code,
    required String cleaningType,
    required String extras,
    required double subtotal,
    String? bookingDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await BookingService.validatePromo(
        code: code,
        cleaningType: cleaningType,
        extras: extras,
        subtotal: subtotal,
        bookingDate: bookingDate,
      );
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
