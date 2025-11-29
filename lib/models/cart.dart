import 'order.dart';

/// Single item in the user's cart.
class CartItem {
  final String id;
  final String productId;
  final int quantity;
  final SelectedVariations selectedVariations;

  const CartItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.selectedVariations,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      productId: json['productId'] as String,
      quantity: json['quantity'] as int,
      selectedVariations: SelectedVariations.fromJson(
        json['selectedVariations'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'quantity': quantity,
      'selectedVariations': selectedVariations.toJson(),
    };
  }
}

/// Cart model for a single user.
class Cart {
  final String userId;
  final List<CartItem> items;
  final DateTime updatedAt;

  const Cart({
    required this.userId,
    required this.items,
    required this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      userId: json['userId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'items': items.map((e) => e.toJson()).toList(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }
}


