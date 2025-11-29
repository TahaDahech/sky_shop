import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

import '../models/cart.dart';
import '../models/live_event.dart';
import '../models/category.dart';
import '../models/notification.dart' as models;
import '../models/order.dart';
import '../models/product.dart';

/// Exception used to simulate HTTP errors from the mock API.
class MockApiException implements Exception {
  final int statusCode;
  final String message;

  const MockApiException(this.statusCode, this.message);

  @override
  String toString() => 'MockApiException($statusCode): $message';
}

/// Mock implementation of the backend API, backed by `mock-api-data.json`.
///
/// This service is structured so it can later be replaced by a real API
/// implementation (e.g. using Dio) without changing the rest of the app.
class MockApiService {
  final _random = Random();

  /// Current user id used for cart and orders.
  final String currentUserId;

  /// Raw decoded JSON data from `mock-api-data.json`.
  Map<String, dynamic>? _data;

  MockApiService({this.currentUserId = 'user_001'});

  /// Loads and caches the mock JSON data from assets.
  Future<void> _loadMockData() async {
    if (_data != null) return;

    try {
      final jsonString =
          await rootBundle.loadString('assets/mock-api-data.json');
      final decoded = json.decode(jsonString);
      if (decoded is Map<String, dynamic>) {
        _data = decoded;
      } else {
        throw Exception('Invalid JSON format: expected Map');
      }
    } catch (e) {
      throw Exception('Failed to load mock data: $e');
    }
  }

  /// Simulates network delay and randomly throws HTTP-like errors.
  Future<T> _withNetworkSimulation<T>(Future<T> Function() body) async {
    // Simulated latency: 200-500ms.
    final delayMs = 200 + _random.nextInt(300);
    await Future.delayed(Duration(milliseconds: delayMs));

    // Small chance to simulate a 500 error.
    final dice = _random.nextDouble();
    if (dice < 0.03) {
      throw const MockApiException(500, 'Erreur serveur simulée');
    }

    return body();
  }

  /// Returns all live events.
  Future<List<LiveEvent>> getLiveEvents() async {
    await _loadMockData();
    return _withNetworkSimulation(() async {
      final eventsJson = _data!['liveEvents'] as List<dynamic>;
      return eventsJson
          .map((e) => LiveEvent.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// Returns a single live event by id.
  Future<LiveEvent> getLiveEventById(String id) async {
    await _loadMockData();
    return _withNetworkSimulation(() async {
      if (_data == null) {
        throw const MockApiException(500, 'Données non chargées');
      }
      final eventsJson = _data!['liveEvents'] as List<dynamic>?;
      if (eventsJson == null) {
        throw const MockApiException(500, 'Aucun événement trouvé dans les données');
      }
      final eventJson = eventsJson.cast<Map<String, dynamic>>().firstWhere(
            (e) => e['id'] == id,
            orElse: () => throw const MockApiException(
              404,
              'Événement introuvable',
            ),
          );
      return LiveEvent.fromJson(eventJson);
    });
  }

  /// Returns all products associated with a given event id.
  Future<List<Product>> getProducts(String eventId) async {
    await _loadMockData();
    return _withNetworkSimulation(() async {
      final eventsJson = _data!['liveEvents'] as List<dynamic>;
      final productsJson = _data!['products'] as List<dynamic>;

      final eventJson = eventsJson.cast<Map<String, dynamic>>().firstWhere(
            (e) => e['id'] == eventId,
            orElse: () => throw const MockApiException(
              404,
              'Événement introuvable',
            ),
          );

      final productIds =
          (eventJson['products'] as List<dynamic>).cast<String>().toSet();

      final filtered = productsJson
          .cast<Map<String, dynamic>>()
          .where((p) => productIds.contains(p['id']))
          .map(Product.fromJson)
          .toList();

      return filtered;
    });
  }

  /// Returns a single product by id.
  Future<Product> getProductById(String id) async {
    await _loadMockData();
    return _withNetworkSimulation(() async {
      final productsJson = _data!['products'] as List<dynamic>;
      final productJson = productsJson.cast<Map<String, dynamic>>().firstWhere(
            (p) => p['id'] == id,
            orElse: () => throw const MockApiException(
              404,
              'Produit introuvable',
            ),
          );
      return Product.fromJson(productJson);
    });
  }

  /// Returns all products.
  Future<List<Product>> getAllProducts() async {
    await _loadMockData();
    return _withNetworkSimulation(() async {
      final productsJson = _data!['products'] as List<dynamic>;
      return productsJson
          .cast<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList();
    });
  }

  /// Adds a product to the current user's cart (in-memory mutation).
  ///
  /// For simplicity, this does not handle product variations; they can be
  /// added later by extending the method signature.
  Future<Cart> addToCart(String productId, int quantity) async {
    await _loadMockData();
    return _withNetworkSimulation(() async {
      _data!.putIfAbsent('cart', () {
        return {
          'userId': currentUserId,
          'items': <Map<String, dynamic>>[],
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        };
      });

      final cartJson = _data!['cart'] as Map<String, dynamic>;
      final items = (cartJson['items'] as List<dynamic>)
          .cast<Map<String, dynamic>>();

      // Try to find an existing item with the same product.
      final existing = items.firstWhere(
        (item) => item['productId'] == productId,
        orElse: () => {},
      );

      if (existing.isNotEmpty) {
        existing['quantity'] =
            (existing['quantity'] as int) + quantity;
      } else {
        final newId = 'cart_item_${items.length + 1}';
        items.add({
          'id': newId,
          'productId': productId,
          'quantity': quantity,
          'selectedVariations': <String, dynamic>{},
        });
      }

      cartJson['updatedAt'] =
          DateTime.now().toUtc().toIso8601String();

      return Cart.fromJson(cartJson);
    });
  }

  /// Returns the current user's cart, creating an empty one if needed.
  Future<Cart> getCart() async {
    await _loadMockData();
    return _withNetworkSimulation(() async {
      if (_data!['cart'] == null) {
        _data!['cart'] = {
          'userId': currentUserId,
          'items': <Map<String, dynamic>>[],
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        };
      }

      final cartJson = _data!['cart'] as Map<String, dynamic>;
      return Cart.fromJson(cartJson);
    });
  }

  /// Finalizes the current cart and creates a new order in the mock data.
  Future<Order> checkout() async {
    await _loadMockData();
    return _withNetworkSimulation(() async {
      final rawCart = _data!['cart'] as Map<String, dynamic>?;
      if (rawCart == null ||
          (rawCart['items'] as List<dynamic>?)?.isEmpty != false) {
        throw const MockApiException(400, 'Le panier est vide');
      }

      final cart = Cart.fromJson(rawCart);

      final productsJson = _data!['products'] as List<dynamic>;
      final ordersJson =
          (_data!['orders'] as List<dynamic>?) ?? <dynamic>[];

      double subtotal = 0;
      final orderItems = <Map<String, dynamic>>[];

      for (final cartItem in cart.items) {
        final productJson = productsJson
            .cast<Map<String, dynamic>>()
            .firstWhere((p) => p['id'] == cartItem.productId);

        final price = (productJson['salePrice'] ?? productJson['price'])
            as num;

        subtotal += price.toDouble() * cartItem.quantity;

        orderItems.add({
          'productId': cartItem.productId,
          'name': productJson['name'],
          'quantity': cartItem.quantity,
          'price': price.toDouble(),
          'selectedVariations':
              cartItem.selectedVariations.values,
        });
      }

      const shipping = 5.99;
      final total = subtotal + shipping;

      final newOrderId = 'order_${ordersJson.length + 1}';

      final orderJson = {
        'id': newOrderId,
        'userId': currentUserId,
        // Link to an event if needed later; left empty for now.
        'liveEventId': '',
        'items': orderItems,
        'subtotal': subtotal,
        'shipping': shipping,
        'total': total,
        'status': 'completed',
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'shippingAddress': {
          'name': 'Mock User',
          'street': '123 Rue de la Demo',
          'city': 'Paris',
          'postalCode': '75000',
          'country': 'France',
        },
      };

      // Persist in-memory.
      if (_data!['orders'] == null) {
        _data!['orders'] = <Map<String, dynamic>>[];
      }
      final ordersList = (_data!['orders'] as List<dynamic>);
      ordersList.add(orderJson);

      // Clear cart after checkout.
      rawCart['items'] = <Map<String, dynamic>>[];
      rawCart['updatedAt'] =
          DateTime.now().toUtc().toIso8601String();

      return Order.fromJson(orderJson);
    });
  }

  /// Returns all orders for the current user.
  Future<List<Order>> getOrders() async {
    await _loadMockData();
    return _withNetworkSimulation(() async {
      final ordersJson =
          (_data!['orders'] as List<dynamic>? ?? <dynamic>[])
              .cast<Map<String, dynamic>>();
      final filtered = ordersJson
          .where((o) => o['userId'] == currentUserId)
          .map(Order.fromJson)
          .toList();
      return filtered;
    });
  }

  /// Returns all categories.
  Future<List<Category>> getCategories() async {
    await _loadMockData();
    return _withNetworkSimulation(() async {
      final categoriesJson = _data!['categories'] as List<dynamic>;
      return categoriesJson
          .cast<Map<String, dynamic>>()
          .map(Category.fromJson)
          .toList();
    });
  }

  /// Returns products filtered by category.
  Future<List<Product>> getProductsByCategory(String categoryName) async {
    await _loadMockData();
    return _withNetworkSimulation(() async {
      final productsJson = _data!['products'] as List<dynamic>;
      return productsJson
          .cast<Map<String, dynamic>>()
          .where((p) => p['category'] == categoryName)
          .map(Product.fromJson)
          .toList();
    });
  }

  /// Searches products by name, description, or category.
  Future<List<Product>> searchProducts(String query) async {
    await _loadMockData();
    return _withNetworkSimulation(() async {
      final productsJson = _data!['products'] as List<dynamic>;
      final lowerQuery = query.toLowerCase();
      return productsJson
          .cast<Map<String, dynamic>>()
          .where((p) {
            final name = (p['name'] as String).toLowerCase();
            final description = (p['description'] as String).toLowerCase();
            final category = (p['category'] as String).toLowerCase();
            return name.contains(lowerQuery) ||
                description.contains(lowerQuery) ||
                category.contains(lowerQuery);
          })
          .map(Product.fromJson)
          .toList();
    });
  }

  /// Returns all notifications for the current user.
  Future<List<models.AppNotification>> getNotifications() async {
    await _loadMockData();
    return _withNetworkSimulation(() async {
      final notificationsJson =
          (_data!['notifications'] as List<dynamic>? ?? <dynamic>[])
              .cast<Map<String, dynamic>>();
      return notificationsJson
          .where((n) => n['userId'] == currentUserId)
          .map(models.AppNotification.fromJson)
          .toList();
    });
  }

  /// Marks a notification as read.
  Future<void> markNotificationAsRead(String notificationId) async {
    await _loadMockData();
    return _withNetworkSimulation(() async {
      final notificationsJson =
          (_data!['notifications'] as List<dynamic>? ?? <dynamic>[])
              .cast<Map<String, dynamic>>();
      final notification = notificationsJson.firstWhere(
        (n) => n['id'] == notificationId,
        orElse: () => throw const MockApiException(
          404,
          'Notification introuvable',
        ),
      );
      notification['read'] = true;
    });
  }
}


