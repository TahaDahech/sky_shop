import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification.dart';
import 'live_event_provider.dart';

/// Provider for all notifications for the current user.
final notificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  final api = ref.watch(mockApiServiceProvider);
  return api.getNotifications();
});

/// Provider for unread notifications count.
final unreadNotificationsCountProvider = FutureProvider<int>((ref) async {
  final notifications = await ref.watch(notificationsProvider.future);
  return notifications.where((n) => !n.read).length;
});

