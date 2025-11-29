import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/live_event.dart';
import '../models/product.dart';
import '../services/mock_api_service.dart';
import 'connectivity_provider.dart';
import 'storage_provider.dart';

/// Provider exposing a singleton [MockApiService].
final mockApiServiceProvider = Provider<MockApiService>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return MockApiService(
    connectivityService: connectivityService,
    storageService: storageService,
  );
});

/// Provider that asynchronously loads all live events from the mock API.
final liveEventsProvider =
    FutureProvider<List<LiveEvent>>((ref) async {
  final api = ref.watch(mockApiServiceProvider);
  return api.getLiveEvents();
});

/// Provider for a single live event by id.
final liveEventByIdProvider =
    FutureProvider.family<LiveEvent, String>((ref, id) async {
  final api = ref.watch(mockApiServiceProvider);
  return api.getLiveEventById(id);
});

/// Provider for products of a specific event.
final eventProductsProvider =
    FutureProvider.family<List<Product>, String>((ref, eventId) async {
  final api = ref.watch(mockApiServiceProvider);
  return api.getProducts(eventId);
});

/// Provider for a single product by id.
final productByIdProvider =
    FutureProvider.family<Product, String>((ref, id) async {
  final api = ref.watch(mockApiServiceProvider);
  return api.getProductById(id);
});

/// Provider for all products (used for "similar products").
final allProductsProvider =
    FutureProvider<List<Product>>((ref) async {
  final api = ref.watch(mockApiServiceProvider);
  return api.getAllProducts();
});

