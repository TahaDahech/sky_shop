import '../models/cart.dart';
import '../models/order.dart';
import '../services/mock_api_service.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';

/// Service that manages cart operations with persistence.
/// Combines mock API service with SharedPreferences for local storage.
class CartService {
  final MockApiService _apiService;
  final StorageService _storageService;
  final AuthService _authService;

  CartService({
    required MockApiService apiService,
    required StorageService storageService,
    required AuthService authService,
  })  : _apiService = apiService,
        _storageService = storageService,
        _authService = authService;

  /// Gets the current cart, loading from SharedPreferences first,
  /// then falling back to the API if not found locally.
  Future<Cart> getCart() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      // Return empty cart if no user is logged in
      return Cart(
        userId: '',
        items: [],
        updatedAt: DateTime.now(),
      );
    }

    // Try to load from SharedPreferences first (priority)
    final savedCart = await _storageService.loadCart(currentUser.id);
    if (savedCart != null) {
      return savedCart;
    }

    // If no saved cart, load from API and save it
    final cart = await _apiService.getCart();
    // Ensure cart has correct userId
    final userCart = Cart(
      userId: currentUser.id,
      items: cart.items,
      updatedAt: cart.updatedAt,
    );
    await _storageService.saveCart(userCart);
    return userCart;
  }

  /// Adds a product to the cart and persists it to SharedPreferences.
  Future<Cart> addToCart(String productId, int quantity) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      throw Exception('User must be logged in to add items to cart');
    }

    // Get current cart (from SharedPreferences if available)
    final cart = await getCart();
    
    // Add item to cart
    final existingItemIndex = cart.items.indexWhere(
      (item) => item.productId == productId,
    );
    
    final updatedItems = <CartItem>[...cart.items];
    if (existingItemIndex >= 0) {
      updatedItems[existingItemIndex] = CartItem(
        id: updatedItems[existingItemIndex].id,
        productId: productId,
        quantity: updatedItems[existingItemIndex].quantity + quantity,
        selectedVariations: updatedItems[existingItemIndex].selectedVariations,
      );
    } else {
      updatedItems.add(CartItem(
        id: 'cart_item_${DateTime.now().millisecondsSinceEpoch}',
        productId: productId,
        quantity: quantity,
        selectedVariations: const SelectedVariations(values: {}),
      ));
    }
    
    final updatedCart = Cart(
      userId: currentUser.id,
      items: updatedItems,
      updatedAt: DateTime.now(),
    );
    
    // Save to SharedPreferences (priority storage)
    await _storageService.saveCart(updatedCart);
    
    return updatedCart;
  }

  /// Removes an item from the cart and persists the change.
  Future<Cart> removeFromCart(String cartItemId) async {
    final cart = await getCart();
    
    // Remove the item
    final updatedItems = cart.items.where((item) => item.id != cartItemId).toList();
    
    // Create updated cart
    final updatedCart = Cart(
      userId: cart.userId,
      items: updatedItems,
      updatedAt: DateTime.now(),
    );
    
    // Save to SharedPreferences
    await _storageService.saveCart(updatedCart);
    
    return updatedCart;
  }

  /// Updates the quantity of a cart item and persists the change.
  Future<Cart> updateCartItemQuantity(String cartItemId, int quantity) async {
    final cart = await getCart();
    
    // Update the item quantity
    final updatedItems = cart.items.map((item) {
      if (item.id == cartItemId) {
        return CartItem(
          id: item.id,
          productId: item.productId,
          quantity: quantity,
          selectedVariations: item.selectedVariations,
        );
      }
      return item;
    }).toList();
    
    // Create updated cart
    final updatedCart = Cart(
      userId: cart.userId,
      items: updatedItems,
      updatedAt: DateTime.now(),
    );
    
    // Save to SharedPreferences
    await _storageService.saveCart(updatedCart);
    
    return updatedCart;
  }

  /// Clears the cart and persists the change.
  Future<Cart> clearCart() async {
    final cart = await getCart();
    
    // Create empty cart
    final emptyCart = Cart(
      userId: cart.userId,
      items: [],
      updatedAt: DateTime.now(),
    );
    
    // Save to SharedPreferences
    await _storageService.saveCart(emptyCart);
    
    return emptyCart;
  }

  /// Performs checkout and saves order to SharedPreferences, then clears the cart.
  Future<Order> checkout({
    required String name,
    required String street,
    required String city,
    required String postalCode,
    required String country,
  }) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      throw Exception('User must be logged in to checkout');
    }

    // Get current cart
    final cart = await getCart();
    if (cart.items.isEmpty) {
      throw Exception('Cart is empty');
    }

    // Fetch product details to get real prices and names
    double subtotal = 0;
    final orderItems = <OrderItem>[];
    
    for (final cartItem in cart.items) {
      try {
        final product = await _apiService.getProductById(cartItem.productId);
        final price = product.salePrice ?? product.price;
        subtotal += price * cartItem.quantity;
        
        orderItems.add(OrderItem(
          productId: cartItem.productId,
          name: product.name,
          quantity: cartItem.quantity,
          price: price,
          selectedVariations: cartItem.selectedVariations,
        ));
      } catch (e) {
        // If product not found, use placeholder
        final placeholderPrice = 1.0;
        subtotal += placeholderPrice * cartItem.quantity;
        orderItems.add(OrderItem(
          productId: cartItem.productId,
          name: 'Product ${cartItem.productId}',
          quantity: cartItem.quantity,
          price: placeholderPrice,
          selectedVariations: cartItem.selectedVariations,
        ));
      }
    }
    
    const shipping = 5.99;
    final total = subtotal + shipping;

    // Create order
    final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
    final order = Order(
      id: orderId,
      userId: currentUser.id,
      liveEventId: '',
      items: orderItems,
      subtotal: subtotal,
      shipping: shipping,
      total: total,
      status: 'pending',
      createdAt: DateTime.now(),
      shippingAddress: ShippingAddress(
        name: name,
        street: street,
        city: city,
        postalCode: postalCode,
        country: country,
      ),
    );

    // Save order to SharedPreferences (priority storage)
    await _storageService.saveOrder(order);
    
    // Clear the cart after successful checkout
    await clearCart();
    
    return order;
  }
}

