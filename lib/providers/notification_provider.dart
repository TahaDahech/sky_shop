import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification.dart';
import 'live_event_provider.dart';

/// Provider for all notifications for the current user.
/// This provider automatically loads from storage and merges with API data.
final notificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  final api = ref.watch(mockApiServiceProvider);
  return api.getNotifications();
});

/// Provider for unread notifications count.
/// Only counts notifications that are not marked as read.
final unreadNotificationsCountProvider = FutureProvider<int>((ref) async {
  final notifications = await ref.watch(notificationsProvider.future);
  return notifications.where((n) => !n.read).length;
});

/// Provider for marking a notification as read.
/// This invalidates the notifications provider to refresh the UI.
final markNotificationAsReadProvider = FutureProvider.family<void, String>((ref, notificationId) async {
  final api = ref.watch(mockApiServiceProvider);
  await api.markNotificationAsRead(notificationId);
  ref.invalidate(notificationsProvider);
  ref.invalidate(unreadNotificationsCountProvider);
});

/// Provider for marking all notifications as read.
final markAllNotificationsAsReadProvider = FutureProvider<void>((ref) async {
  final api = ref.watch(mockApiServiceProvider);
  await api.markAllNotificationsAsRead();
  ref.invalidate(notificationsProvider);
  ref.invalidate(unreadNotificationsCountProvider);
});

/// Provider for deleting a notification.
final deleteNotificationProvider = FutureProvider.family<bool, String>((ref, notificationId) async {
  final api = ref.watch(mockApiServiceProvider);
  final success = await api.deleteNotification(notificationId);
  if (success) {
    ref.invalidate(notificationsProvider);
    ref.invalidate(unreadNotificationsCountProvider);
  }
  return success;
});

/// Provider for deleting all notifications.
final deleteAllNotificationsProvider = FutureProvider<bool>((ref) async {
  final api = ref.watch(mockApiServiceProvider);
  final success = await api.deleteAllNotifications();
  if (success) {
    ref.invalidate(notificationsProvider);
    ref.invalidate(unreadNotificationsCountProvider);
  }
  return success;
});

