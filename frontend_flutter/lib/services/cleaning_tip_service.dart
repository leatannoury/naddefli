// =============================================================================
// NADDEFLI — cleaning_tip_service.dart
// Layer: Flutter — Service
// Purpose: Fetches tip-of-the-day for home screen.
// Connects to: GET /api/cleaning-tips/tip-of-the-day
// =============================================================================

import 'package:flutter/foundation.dart';
import 'http_service.dart';
import '../utils/constants.dart';

class CleaningTipService {
  static Map<String, dynamic>? _cachedTip;
  static String? _cachedDate;

  static Future<Map<String, dynamic>?> getTipOfTheDay({
    bool forceRefresh = false,
  }) async {
    final today = DateTime.now().toIso8601String().split('T').first;
    if (!forceRefresh && _cachedTip != null && _cachedDate == today) {
      return _cachedTip;
    }

    try {
      final response = await HttpService.get(
        '${ApiEndpoints.baseOrigin}/api/cleaning-tips/tip-of-the-day',
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map) {
          _cachedTip = Map<String, dynamic>.from(data);
          _cachedDate = today;
          return _cachedTip;
        }
      }
    } catch (e) {
      debugPrint('Failed to load cleaning tip: $e');
    }
    return null;
  }
}
