/// Service Model
import 'dart:convert';
class Service {
  final String id;
  final String name;
  final String? description;
  final double basePrice;
  final double durationHours;
  final String? image;
  final String? imageUrl;
  final DateTime? createdAt;
  final List<Map<String, dynamic>> addOns;

  Service({
    required this.id,
    required this.name,
    this.description,
    required this.basePrice,
    required this.durationHours,
    this.image,
    this.imageUrl,
    this.createdAt,
    this.addOns = const [],
  });

  /// Factory constructor for JSON deserialization
  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      basePrice: double.parse(json['base_price'].toString()),
      durationHours: double.parse(json['duration_hours'].toString()),
      image: json['image'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      addOns: (() {
        try {
          final raw = json['add_ons'];
          if (raw == null) return <Map<String, dynamic>>[];
          if (raw is String) {
            if (raw.trim().isEmpty) return <Map<String, dynamic>>[];
            final parsed = jsonDecode(raw) as List;
            return parsed.map((e) => e is Map ? Map<String, dynamic>.from(e) : {'name': e.toString(), 'price': 0}).toList();
          }
          if (raw is List) return raw.map((e) => e is Map ? Map<String, dynamic>.from(e) : {'name': e.toString(), 'price': 0}).toList();
        } catch (_) {}
        return <Map<String, dynamic>>[];
      })(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'base_price': basePrice,
      'duration_hours': durationHours,
      'image': image,
      'image_url': imageUrl,
      'add_ons': addOns,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
