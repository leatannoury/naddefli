import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../utils/app_styles.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await NotificationService.fetchNotifications();
      await NotificationService.markAllRead();
      if (mounted) setState(() => _items = list);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  IconData _iconFor(String? type) {
    switch (type) {
      case 'booking_accepted':
        return Icons.check_circle_outline;
      case 'booking_completed':
        return Icons.done_all;
      case 'booking_cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.calendar_month_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Text('No notifications yet', style: TextStyle(color: AppColors.primary.withValues(alpha: 0.5))),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final n = _items[index] as Map<String, dynamic>;
                      final isRead = n['is_read'] == true;
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: isRead ? const Color(0xFFE2E8F0) : AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: ListTile(
                          leading: Icon(_iconFor(n['type']?.toString()), color: AppColors.primary),
                          title: Text(
                            n['title']?.toString() ?? 'Update',
                            style: TextStyle(fontWeight: isRead ? FontWeight.w500 : FontWeight.bold),
                          ),
                          subtitle: Text(n['body']?.toString() ?? ''),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
