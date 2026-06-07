import 'constants.dart';

/// Resolve service image URL from API response or stored path.
/// Handles the case where the backend returns a localhost URL that must
/// be replaced with the actual API_ORIGIN when running on a physical device.
String? resolveServiceImageUrl(String? image, {String? imageUrl}) {
  // Prefer the pre-resolved image_url from the API response
  final raw = (imageUrl != null && imageUrl.trim().isNotEmpty)
      ? imageUrl.trim()
      : (image != null ? image.trim() : '');

  if (raw.isEmpty) return null;

  String url;

  if (raw.startsWith('http://') ||
      raw.startsWith('https://') ||
      raw.startsWith('data:image')) {
    url = raw;
  } else {
    // Relative path — build full URL from API_ORIGIN
    final normalized = raw.startsWith('/') ? raw.substring(1) : raw;
    if (normalized.startsWith('uploads/')) {
      url = '$API_ORIGIN/$normalized';
    } else {
      url = '$API_ORIGIN/uploads/$normalized';
    }
  }

  // Replace localhost / 127.0.0.1 with the configured API_ORIGIN host so
  // images load correctly on physical devices / different emulators.
  try {
    final uri = Uri.parse(url);
    final originUri = Uri.parse(API_ORIGIN);
    if (uri.host == 'localhost' ||
        uri.host == '127.0.0.1' ||
        uri.host.isEmpty) {
      url = uri
          .replace(
            host: originUri.host,
            port: originUri.port,
          )
          .toString();
    }
  } catch (_) {
    // If URL parsing fails, return as-is
  }

  return url;
}
