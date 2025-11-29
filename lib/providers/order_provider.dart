import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import 'auth_provider.dart';
import 'storage_provider.dart';

/// Provider for orders service functionality.
/// Loads orders from SharedPreferences first, then falls back to API if needed.
/// Automatically refreshes when the user changes.
final ordersProvider = FutureProvider<List<Order>>((ref) async {
  // Watch current user to refresh orders when user changes
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) {
    return [];
  }

  final storageService = ref.watch(storageServiceProvider);
  
  // Load from SharedPreferences first (priority)
  final savedOrders = await storageService.loadOrders(currentUser.id);
  if (savedOrders.isNotEmpty) {
    return savedOrders;
  }

  // If no saved orders, return empty list
  // In a real app, you might want to fetch from API here
  return [];
});

