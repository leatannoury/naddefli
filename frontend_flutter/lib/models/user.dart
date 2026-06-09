// =============================================================================
// NADDEFLI — user.dart
// Layer: Flutter — Model
// Purpose: Data class representing a user (id, name, email, loyalty fields). fromJson/toJson.
// Connects to: Parsed from /api/auth responses
// =============================================================================

/// User Model
class User {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String role; // customer, cleaner, admin
  final int completedBookingsCount;
  final int loyaltyProgress;
  final int loyaltyRewardsAvailable;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    this.completedBookingsCount = 0,
    this.loyaltyProgress = 0,
    this.loyaltyRewardsAvailable = 0,
    this.createdAt,
  });

  /// Factory constructor for JSON deserialization
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'customer',
      completedBookingsCount:
          int.tryParse(json['completed_bookings_count']?.toString() ?? '') ?? 0,
      loyaltyProgress:
          int.tryParse(json['loyalty_progress']?.toString() ?? '') ?? 0,
      loyaltyRewardsAvailable:
          int.tryParse(json['loyalty_rewards_available']?.toString() ?? '') ??
              0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'completed_bookings_count': completedBookingsCount,
      'loyalty_progress': loyaltyProgress,
      'loyalty_rewards_available': loyaltyRewardsAvailable,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Create a copy with modifications
  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? role,
    int? completedBookingsCount,
    int? loyaltyProgress,
    int? loyaltyRewardsAvailable,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      completedBookingsCount:
          completedBookingsCount ?? this.completedBookingsCount,
      loyaltyProgress: loyaltyProgress ?? this.loyaltyProgress,
      loyaltyRewardsAvailable:
          loyaltyRewardsAvailable ?? this.loyaltyRewardsAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
