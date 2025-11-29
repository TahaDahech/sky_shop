import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/live_event_provider.dart';

/// Provider that calculates cart totals with actual product prices.
/// Returns a map with 'subtotal', 'shipping', and 'total'.
/// Also returns a list of cart items with their product details.
class CartTotals {
  final double subtotal;
  final double shipping;
  final double total;
  final List<CartItemWithProduct> items;

  CartTotals({
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.items,
  });
}

class CartItemWithProduct {
  final CartItem cartItem;
  final Product product;
  final double itemTotal;

  CartItemWithProduct({
    required this.cartItem,
    required this.product,
    required this.itemTotal,
  });
}

/// Provider that fetches all products for cart items and calculates totals.
final cartTotalsProvider = FutureProvider<CartTotals>((ref) async {
  final cart = await ref.watch(cartProvider.future);
  
  if (cart.items.isEmpty) {
    return CartTotals(
      subtotal: 0,
      shipping: 5.99,
      total: 5.99,
      items: [],
    );
  }

  // Fetch all products for cart items
  final itemsWithProducts = <CartItemWithProduct>[];
  double subtotal = 0;

  for (final cartItem in cart.items) {
    try {
      final product = await ref.watch(
        productByIdProvider(cartItem.productId).future,
      );
      final price = product.salePrice ?? product.price;
      final itemTotal = price * cartItem.quantity;
      subtotal += itemTotal;

      itemsWithProducts.add(CartItemWithProduct(
        cartItem: cartItem,
        product: product,
        itemTotal: itemTotal,
      ));
    } catch (e) {
      // If product not found, use placeholder
      final placeholderPrice = 0.0;
      final itemTotal = placeholderPrice * cartItem.quantity;
      
      // Create a placeholder product
      final placeholderProduct = Product(
        id: cartItem.productId,
        name: 'Product ${cartItem.productId}',
        description: '',
        price: placeholderPrice,
        images: [],
        thumbnail: '',
        stock: 0,
        isFeatured: false,
        category: '',
        rating: 0,
        reviewsCount: 0,
      );

      itemsWithProducts.add(CartItemWithProduct(
        cartItem: cartItem,
        product: placeholderProduct,
        itemTotal: itemTotal,
      ));
    }
  }

  const shipping = 5.99;
  final total = subtotal + shipping;

  return CartTotals(
    subtotal: subtotal,
    shipping: shipping,
    total: total,
    items: itemsWithProducts,
  );
});

