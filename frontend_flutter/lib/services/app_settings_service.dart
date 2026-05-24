import '../utils/constants.dart';
import 'http_service.dart';

class AppSettingsService {
  static Map<String, dynamic>? _cache;

  static Future<Map<String, dynamic>> getPublicSettings({bool forceRefresh = false}) async {
    if (_cache != null && !forceRefresh) return _cache!;

    try {
      final response = await HttpService.get('${ApiEndpoints.baseOrigin}/settings/public');
      if (response.statusCode == 200 && response.data['success'] == true) {
        _cache = Map<String, dynamic>.from(response.data['data'] ?? {});
        return _cache!;
      }
    } catch (_) {
      // fall through to defaults
    }

    return {
      'supportPhone': '+961 00 000 000',
      'supportEmail': 'support@naddefli.local',
      'normalHourlyRate': 4.0,
      'deepHourlyRate': 6.0,
    };
  }
}
