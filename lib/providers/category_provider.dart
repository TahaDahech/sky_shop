import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../models/product.dart';
import 'live_event_provider.dart';

/// Provider for all categories.
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final api = ref.watch(mockApiServiceProvider);
  return api.getCategories();
});

/// Provider for products by category name.
final productsByCategoryProvider =
    FutureProvider.family<List<Product>, String>((ref, categoryName) async {
  final api = ref.watch(mockApiServiceProvider);
  return api.getProductsByCategory(categoryName);
});

