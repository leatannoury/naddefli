/// Service Model
class Service {
  final String id;
  final String name;
  final String? description;
  final double basePrice;
  final double durationHours;
  final String? image;
  final String? imageUrl;
  final DateTime? createdAt;

  Service({
    required this.id,
    required this.name,
    this.description,
    required this.basePrice,
    required this.durationHours,
    this.image,
    this.imageUrl,
    this.createdAt,
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
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
