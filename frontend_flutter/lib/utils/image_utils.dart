const API_ORIGIN = 'http://192.168.1.107:5000';

/// Resolve service image URL from API response or stored path.
String? resolveServiceImageUrl(String? image, {String? imageUrl}) {
  if (imageUrl != null && imageUrl.trim().isNotEmpty) return imageUrl.trim();
  if (image == null || image.trim().isEmpty) return null;
  final trimmed = image.trim();
  if (trimmed.startsWith('http://') ||
      trimmed.startsWith('https://') ||
      trimmed.startsWith('data:image')) {
    return trimmed;
  }
  final normalized = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
  if (normalized.startsWith('uploads/')) {
    return '$API_ORIGIN/$normalized';
  }
  return '$API_ORIGIN/uploads/$normalized';
}
