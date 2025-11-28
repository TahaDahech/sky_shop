import '../models/cart.dart';
import '../models/order.dart';
import '../services/mock_api_service.dart';
import '../services/storage_service.dart';

/// Service that manages cart operations with persistence.
/// Combines mock API service with SharedPreferences for local storage.
class CartService {
  final MockApiService _apiService;
  final StorageService _storageService;

  CartService({
    required MockApiService apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  /// Gets the current cart, loading from SharedPreferences first,
  /// then falling back to the API if not found locally.
  Future<Cart> getCart() async {
    // Try to load from SharedPreferences first
    final savedCart = await _storageService.loadCart();
    if (savedCart != null) {
      return savedCart;
    }

    // If no saved cart, load from API and save it
    final cart = await _apiService.getCart();
    await _storageService.saveCart(cart);
    return cart;
  }

  /// Adds a product to the cart and persists it to SharedPreferences.
  Future<Cart> addToCart(String productId, int quantity) async {
    // Add to cart via API
    final cart = await _apiService.addToCart(productId, quantity);
    
    // Save to SharedPreferences
    await _storageService.saveCart(cart);
    
    return cart;
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

  /// Performs checkout using the API and clears the cart from storage.
  Future<Order> checkout() async {
    // Use the API to checkout
    final order = await _apiService.checkout();
    
    // Clear the cart after successful checkout
    await clearCart();
    
    return order;
  }
}

