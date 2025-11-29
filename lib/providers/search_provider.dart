import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import 'live_event_provider.dart';

/// Provider for search results.
final searchResultsProvider =
    FutureProvider.family<List<Product>, String>((ref, query) async {
  if (query.isEmpty) {
    return [];
  }
  final api = ref.watch(mockApiServiceProvider);
  return api.searchProducts(query);
});

