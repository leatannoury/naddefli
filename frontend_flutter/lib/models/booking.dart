/// Booking Model
class Booking {
  final String id;
  final String userId;
  final String? cleanerId;
  final String serviceId;
  final DateTime bookingDate;
  final String bookingTime;
  final String startTime;
  final String endTime;
  final double durationHours;
  final double discountAmount;
  final String? promoCode;
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
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.discountAmount,
    this.promoCode,
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
    final dateValue = json['booking_date']?.toString();
    final totalValue = double.tryParse(json['total_price']?.toString() ?? '');
    final durationValue = double.tryParse(json['duration_hours']?.toString() ?? '');
    final discountValue = double.tryParse(json['discount_amount']?.toString() ?? '');

    return Booking(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      cleanerId: json['cleaner_id'],
      serviceId: json['service_id'] ?? '',
      bookingDate: dateValue == null
          ? DateTime.now()
          : (DateTime.tryParse(dateValue) ?? DateTime.now()),
      bookingTime: json['booking_time'] ?? '',
      startTime: json['start_time'] ?? json['booking_time'] ?? '',
      endTime: json['end_time'] ?? '',
      durationHours: durationValue ?? 1.0,
      discountAmount: discountValue ?? 0.0,
      promoCode: json['promo_code'],
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      notes: json['notes'],
      totalPrice: totalValue ?? 0,
      status: json['status'] ?? 'pending',
      isCustom: json['is_custom'] == 1 ||
          json['is_custom'] == true ||
          json['is_custom'] == 'true',
      propertyType: json['property_type'],
      roomCount: int.tryParse(json['room_count']?.toString() ?? '') ?? 0,
      bathroomsCount:
          int.tryParse(json['bathrooms_count']?.toString() ?? '') ?? 0,
      kitchensCount:
          int.tryParse(json['kitchens_count']?.toString() ?? '') ?? 0,
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
      'start_time': startTime,
      'end_time': endTime,
      'duration_hours': durationHours,
      'discount_amount': discountAmount,
      'promo_code': promoCode,
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
