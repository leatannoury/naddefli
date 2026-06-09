// =============================================================================
// NADDEFLI — address.dart
// Layer: Flutter — Model
// Purpose: Data class for a saved customer address.
// Connects to: Parsed from /api/addresses
// =============================================================================

/// Saved Address Model
class Address {
  final String id;
  final String userId;
  final String label; // Home, Work, Other
  final String address;
  final String city;
  final String? building;
  final String? floor;
  final String? notes;
  final DateTime? createdAt;

  Address({
    required this.id,
    required this.userId,
    required this.label,
    required this.address,
    required this.city,
    this.building,
    this.floor,
    this.notes,
    this.createdAt,
  });

  /// Factory constructor for JSON deserialization
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      label: json['label'] ?? 'Home',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      building: json['building'],
      floor: json['floor'],
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'label': label,
      'address': address,
      'city': city,
      'building': building,
      'floor': floor,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
