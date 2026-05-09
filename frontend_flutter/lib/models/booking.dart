/// Booking Model
class Booking {
  final String id;
  final String userId;
  final String? cleanerId;
  final String serviceId;
  final DateTime bookingDate;
  final String bookingTime;
  final String address;
  final String city;
  final String? notes;
  final double totalPrice;
  final String status; // pending, accepted, on_the_way, started, completed, cancelled
  final bool isCustom;
  final String? propertyType;
  final int roomCount;
  final int bathroomsCount;
  final int kitchensCount;
  final String cleaningType;
  final String? extras;
  final DateTime? createdAt;

  Booking({
    required this.id,
    required this.userId,
    this.cleanerId,
    required this.serviceId,
    required this.bookingDate,
    required this.bookingTime,
    required this.address,
    required this.city,
    this.notes,
    required this.totalPrice,
    required this.status,
    this.isCustom = false,
    this.propertyType,
    this.roomCount = 0,
    this.bathroomsCount = 0,
    this.kitchensCount = 0,
    this.cleaningType = 'normal',
    this.extras,
    this.createdAt,
  });

  /// Factory constructor for JSON deserialization
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      cleanerId: json['cleaner_id'],
      serviceId: json['service_id'] ?? '',
      bookingDate: DateTime.parse(json['booking_date']),
      bookingTime: json['booking_time'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      notes: json['notes'],
      totalPrice: double.parse(json['total_price'].toString()),
      status: json['status'] ?? 'pending',
      isCustom: json['is_custom'] == 1 || json['is_custom'] == true,
      propertyType: json['property_type'],
      roomCount: json['room_count'] ?? 0,
      bathroomsCount: json['bathrooms_count'] ?? 0,
      kitchensCount: json['kitchens_count'] ?? 0,
      cleaningType: json['cleaning_type'] ?? 'normal',
      extras: json['extras'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'cleaner_id': cleanerId,
      'service_id': serviceId,
      'booking_date': bookingDate.toIso8601String(),
      'booking_time': bookingTime,
      'address': address,
      'city': city,
      'notes': notes,
      'total_price': totalPrice,
      'status': status,
      'is_custom': isCustom,
      'property_type': propertyType,
      'room_count': roomCount,
      'bathrooms_count': bathroomsCount,
      'kitchens_count': kitchensCount,
      'cleaning_type': cleaningType,
      'extras': extras,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Get readable status
  String getStatusLabel() {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'on_the_way':
        return 'On the Way';
      case 'started':
        return 'Started';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
