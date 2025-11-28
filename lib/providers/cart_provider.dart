import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart.dart';
import '../services/cart_service.dart';
import 'live_event_provider.dart';
import 'storage_provider.dart';

/// Provider for the CartService instance.
final cartServiceProvider = Provider<CartService>((ref) {
  final api = ref.watch(mockApiServiceProvider);
  final storage = ref.watch(storageServiceProvider);
  return CartService(apiService: api, storageService: storage);
});

/// Future-based provider exposing the current cart with persistence.
/// Loads from SharedPreferences first, then falls back to API.
final cartProvider = FutureProvider<Cart>((ref) async {
  final cartService = ref.watch(cartServiceProvider);
  return cartService.getCart();
});

