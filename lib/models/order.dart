/// Selected variations for an order/cart line item (e.g. size, color).
class SelectedVariations {
  /// Key/value pairs, e.g. { "size": "M", "color": "Bleu" }
  final Map<String, String> values;

  const SelectedVariations({required this.values});

  factory SelectedVariations.fromJson(Map<String, dynamic> json) {
    final map = <String, String>{};
    for (final entry in json.entries) {
      map[entry.key] = entry.value.toString();
    }
    return SelectedVariations(values: map);
  }

  Map<String, dynamic> toJson() {
    return values.map((key, value) => MapEntry(key, value));
  }
}

/// Single item within an order.
class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final SelectedVariations selectedVariations;

  const OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.selectedVariations,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      selectedVariations: SelectedVariations.fromJson(
        json['selectedVariations'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'selectedVariations': selectedVariations.toJson(),
    };
  }
}

/// Shipping address for an order.
class ShippingAddress {
  final String name;
  final String street;
  final String city;
  final String postalCode;
  final String country;

  const ShippingAddress({
    required this.name,
    required this.street,
    required this.city,
    required this.postalCode,
    required this.country,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      name: json['name'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      postalCode: json['postalCode'] as String,
      country: json['country'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'street': street,
      'city': city,
      'postalCode': postalCode,
      'country': country,
    };
  }
}

/// Order model corresponding to entries in `orders` in the JSON.
class Order {
  final String id;
  final String userId;
  final String liveEventId;
  final List<OrderItem> items;
  final double subtotal;
  final double shipping;
  final double total;
  final String status;
  final DateTime createdAt;
  final ShippingAddress shippingAddress;

  const Order({
    required this.id,
    required this.userId,
    required this.liveEventId,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.shippingAddress,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['userId'] as String,
      liveEventId: json['liveEventId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      shipping: (json['shipping'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      shippingAddress: ShippingAddress.fromJson(
        json['shippingAddress'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'liveEventId': liveEventId,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'shipping': shipping,
      'total': total,
      'status': status,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'shippingAddress': shippingAddress.toJson(),
    };
  }
}

