// =============================================================================
// NADDEFLI — service_provider.dart
// Layer: Flutter — State (Provider)
// Purpose: Loads and caches the service catalog from the API.
// Connects to: ServiceApiService → GET /api/services
// =============================================================================

import 'package:flutter/material.dart';
import '../models/service.dart';
import '../services/service_api_service.dart';

/// Service Provider for state management
class ServiceProvider extends ChangeNotifier {
  List<Service> _services = [];
  Service? _selectedService;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Service> get services => _services;
  Service? get selectedService => _selectedService;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all services
  Future<void> fetchServices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ServiceApiService.getServices();

      if (result['success']) {
        final servicesList = result['data'] as List;
        _services =
            servicesList.map((s) => Service.fromJson(s)).toList();
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

  /// Get service by ID
  Future<void> fetchServiceById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ServiceApiService.getServiceById(id);

      if (result['success']) {
        _selectedService = Service.fromJson(result['data']);
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

  /// Select service
  void selectService(Service service) {
    _selectedService = service;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
