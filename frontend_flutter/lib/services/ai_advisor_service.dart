// =============================================================================
// NADDEFLI — ai_advisor_service.dart
// Layer: Flutter — Service (AI)
// Purpose: Sends quiz answers to backend AI recommendation endpoint.
// Connects to: POST /api/ai/service-recommendation
// =============================================================================

import '../utils/constants.dart';
import 'http_service.dart';

class AiAdvisorService {
  static Future<Map<String, dynamic>?> getRecommendation(
    Map<String, String> answers,
  ) async {
    try {
      final response = await HttpService.post(
        '${ApiEndpoints.baseOrigin}/api/ai/service-recommendation',
        data: {'answers': answers},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
      }
    } catch (_) {}
    return null;
  }
}
