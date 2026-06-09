// =============================================================================
// NADDEFLI — app_settings_service.dart
// Layer: Flutter — Service
// Purpose: Fetches public business settings (hourly rates, support contact).
// Connects to: GET /api/settings/public
// =============================================================================

import '../utils/constants.dart';
import 'http_service.dart';

class AppSettingsService {
  static Map<String, dynamic>? _cache;

  static List<Map<String, dynamic>> _normalizeAddOns(dynamic raw) {
    if (raw is! List) return <Map<String, dynamic>>[];

    return raw
        .whereType<Map>()
        .map((addon) => Map<String, dynamic>.from(addon))
        .where((addon) {
      final name = (addon['name'] ?? addon['title'] ?? '').toString();
      return name.trim().isNotEmpty;
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> getPublicAddOns({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cache?['globalAddOns'] is List) {
      return _normalizeAddOns(_cache!['globalAddOns']);
    }

    try {
      final response =
          await HttpService.get('${ApiEndpoints.baseOrigin}/api/addons');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final addons = _normalizeAddOns(response.data['data']);
        _cache ??= <String, dynamic>{};
        _cache!['globalAddOns'] = addons;
        return addons;
      }
    } catch (_) {}

    return <Map<String, dynamic>>[];
  }

  static Future<Map<String, dynamic>> getPublicSettings(
      {bool forceRefresh = false}) async {
    if (_cache != null && !forceRefresh) return _cache!;

    try {
      final response = await HttpService.get(
          '${ApiEndpoints.baseOrigin}/api/settings/public');
      if (response.statusCode == 200 && response.data['success'] == true) {
        _cache = Map<String, dynamic>.from(response.data['data'] ?? {});
        _cache!['globalAddOns'] = await getPublicAddOns(forceRefresh: true);
        return _cache!;
      }
    } catch (_) {
      // fall through to defaults
    }

    final addons = await getPublicAddOns(forceRefresh: forceRefresh);
    return {
      'supportPhone': '+961 00 000 000',
      'supportEmail': 'support@naddefli.local',
      'normalHourlyRate': 4.0,
      'deepHourlyRate': 6.0,
      'globalAddOns': addons,
    };
  }
}
