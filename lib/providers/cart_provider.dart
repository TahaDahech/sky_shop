import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart.dart';
import '../services/cart_service.dart';
import 'auth_provider.dart';
import 'live_event_provider.dart';
import 'storage_provider.dart';

/// Provider for the CartService instance.
final cartServiceProvider = Provider<CartService>((ref) {
  final api = ref.watch(mockApiServiceProvider);
  final storage = ref.watch(storageServiceProvider);
  final auth = ref.watch(authServiceProvider);
  return CartService(
    apiService: api,
    storageService: storage,
    authService: auth,
  );
});

/// Future-based provider exposing the current cart with persistence.
/// Loads from SharedPreferences first, then falls back to API.
/// Automatically refreshes when the user changes.
final cartProvider = FutureProvider<Cart>((ref) async {
  // Watch current user to refresh cart when user changes
  ref.watch(currentUserProvider);
  final cartService = ref.watch(cartServiceProvider);
  return cartService.getCart();
});

