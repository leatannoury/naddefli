import '../utils/constants.dart';
import 'http_service.dart';

class NotificationService {
  static Future<List<dynamic>> fetchNotifications() async {
    final response = await HttpService.get(ApiEndpoints.notifications);
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data'] as List<dynamic>? ?? [];
    }
    return [];
  }

  static Future<int> fetchUnreadCount() async {
    try {
      final response = await HttpService.get('${ApiEndpoints.notifications}/unread-count');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['unreadCount'] as int? ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  static Future<void> markAllRead() async {
    await HttpService.put(ApiEndpoints.markAllAsRead, data: {});
  }
}
