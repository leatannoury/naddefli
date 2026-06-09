// =============================================================================
// NADDEFLI — address_provider.dart
// Layer: Flutter — State (Provider)
// Purpose: Manages saved addresses state for the current user.
// Connects to: AddressService → /api/addresses
// =============================================================================

import 'package:flutter/material.dart';
import '../models/address.dart';
import '../services/address_service.dart';

class AddressProvider extends ChangeNotifier {
  List<Address> _addresses = [];
  bool _isLoading = false;
  String? _error;

  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch saved addresses
  Future<void> fetchAddresses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await AddressService.fetchAddresses();
    _isLoading = false;

    if (result['success']) {
      final List<dynamic> list = result['data'] ?? [];
      _addresses = list.map((item) => Address.fromJson(item)).toList();
    } else {
      _error = result['message'];
    }
    notifyListeners();
  }

  /// Add new address
  Future<bool> addAddress({
    required String label,
    required String address,
    required String city,
    String? building,
    String? floor,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await AddressService.addAddress(
      label: label,
      address: address,
      city: city,
      building: building,
      floor: floor,
      notes: notes,
    );
    _isLoading = false;

    if (result['success']) {
      final newAddr = Address.fromJson(result['data']);
      _addresses.insert(0, newAddr);
      notifyListeners();
      return true;
    } else {
      _error = result['message'];
      notifyListeners();
      return false;
    }
  }

  /// Edit Address
  Future<bool> updateAddress({
    required String id,
    required String label,
    required String address,
    required String city,
    String? building,
    String? floor,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await AddressService.updateAddress(
      id: id,
      label: label,
      address: address,
      city: city,
      building: building,
      floor: floor,
      notes: notes,
    );
    _isLoading = false;

    if (result['success']) {
      final updatedAddr = Address.fromJson(result['data']);
      final index = _addresses.indexWhere((a) => a.id == id);
      if (index != -1) {
        _addresses[index] = updatedAddr;
      }
      notifyListeners();
      return true;
    } else {
      _error = result['message'];
      notifyListeners();
      return false;
    }
  }

  /// Delete Address
  Future<bool> deleteAddress(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await AddressService.deleteAddress(id);
    _isLoading = false;

    if (result['success']) {
      _addresses.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } else {
      _error = result['message'];
      notifyListeners();
      return false;
    }
  }
}
