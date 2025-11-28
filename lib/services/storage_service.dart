import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart.dart';

/// Service for managing local storage using SharedPreferences.
/// Handles cart persistence and other user interactions.
class StorageService {
  static const String _cartKey = 'cart_data';
  static const String _favoritesKey = 'favorite_products';
  static const String _recentlyViewedKey = 'recently_viewed_products';
  static const String _userIdKey = 'current_user_id';
  static const String _userPreferencesKey = 'user_preferences';

  /// Gets the SharedPreferences instance.
  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // ==================== Cart Operations ====================

  /// Saves the cart to local storage.
  Future<bool> saveCart(Cart cart) async {
    try {
      final prefs = await _prefs;
      final cartJson = jsonEncode(cart.toJson());
      return await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      return false;
    }
  }

  /// Loads the cart from local storage.
  /// Returns null if no cart is saved.
  Future<Cart?> loadCart() async {
    try {
      final prefs = await _prefs;
      final cartJson = prefs.getString(_cartKey);
      if (cartJson == null) return null;

      final cartMap = jsonDecode(cartJson) as Map<String, dynamic>;
      return Cart.fromJson(cartMap);
    } catch (e) {
      return null;
    }
  }

  /// Clears the cart from local storage.
  Future<bool> clearCart() async {
    try {
      final prefs = await _prefs;
      return await prefs.remove(_cartKey);
    } catch (e) {
      return false;
    }
  }

  // ==================== Favorites Operations ====================

  /// Adds a product ID to favorites.
  Future<bool> addToFavorites(String productId) async {
    try {
      final favorites = await getFavorites();
      if (!favorites.contains(productId)) {
        favorites.add(productId);
        return await _saveFavorites(favorites);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Removes a product ID from favorites.
  Future<bool> removeFromFavorites(String productId) async {
    try {
      final favorites = await getFavorites();
      favorites.remove(productId);
      return await _saveFavorites(favorites);
    } catch (e) {
      return false;
    }
  }

  /// Gets the list of favorite product IDs.
  Future<List<String>> getFavorites() async {
    try {
      final prefs = await _prefs;
      final favoritesJson = prefs.getString(_favoritesKey);
      if (favoritesJson == null) return [];

      final favoritesList = jsonDecode(favoritesJson) as List<dynamic>;
      return favoritesList.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  /// Checks if a product is in favorites.
  Future<bool> isFavorite(String productId) async {
    final favorites = await getFavorites();
    return favorites.contains(productId);
  }

  /// Saves the favorites list to local storage.
  Future<bool> _saveFavorites(List<String> favorites) async {
    try {
      final prefs = await _prefs;
      final favoritesJson = jsonEncode(favorites);
      return await prefs.setString(_favoritesKey, favoritesJson);
    } catch (e) {
      return false;
    }
  }

  // ==================== Recently Viewed Operations ====================

  /// Adds a product ID to recently viewed (with a limit of 20 items).
  Future<bool> addToRecentlyViewed(String productId) async {
    try {
      final recentlyViewed = await getRecentlyViewed();
      // Remove if already exists to avoid duplicates
      recentlyViewed.remove(productId);
      // Add to the beginning
      recentlyViewed.insert(0, productId);
      // Keep only the last 20 items
      if (recentlyViewed.length > 20) {
        recentlyViewed.removeRange(20, recentlyViewed.length);
      }
      return await _saveRecentlyViewed(recentlyViewed);
    } catch (e) {
      return false;
    }
  }

  /// Gets the list of recently viewed product IDs.
  Future<List<String>> getRecentlyViewed() async {
    try {
      final prefs = await _prefs;
      final recentlyViewedJson = prefs.getString(_recentlyViewedKey);
      if (recentlyViewedJson == null) return [];

      final recentlyViewedList = jsonDecode(recentlyViewedJson) as List<dynamic>;
      return recentlyViewedList.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  /// Saves the recently viewed list to local storage.
  Future<bool> _saveRecentlyViewed(List<String> recentlyViewed) async {
    try {
      final prefs = await _prefs;
      final recentlyViewedJson = jsonEncode(recentlyViewed);
      return await prefs.setString(_recentlyViewedKey, recentlyViewedJson);
    } catch (e) {
      return false;
    }
  }

  // ==================== User ID Operations ====================

  /// Saves the current user ID.
  Future<bool> saveUserId(String userId) async {
    try {
      final prefs = await _prefs;
      return await prefs.setString(_userIdKey, userId);
    } catch (e) {
      return false;
    }
  }

  /// Gets the current user ID.
  Future<String?> getUserId() async {
    try {
      final prefs = await _prefs;
      return prefs.getString(_userIdKey);
    } catch (e) {
      return null;
    }
  }

  /// Clears the current user ID.
  Future<bool> clearUserId() async {
    try {
      final prefs = await _prefs;
      return await prefs.remove(_userIdKey);
    } catch (e) {
      return false;
    }
  }

  // ==================== User Preferences Operations ====================

  /// Saves a user preference.
  Future<bool> savePreference(String key, dynamic value) async {
    try {
      final prefs = await _prefs;
      final preferences = await getPreferences();

      if (value is String) {
        preferences[key] = value;
      } else if (value is int) {
        preferences[key] = value;
      } else if (value is double) {
        preferences[key] = value;
      } else if (value is bool) {
        preferences[key] = value;
      } else {
        preferences[key] = value.toString();
      }

      final preferencesJson = jsonEncode(preferences);
      return await prefs.setString(_userPreferencesKey, preferencesJson);
    } catch (e) {
      return false;
    }
  }

  /// Gets a user preference by key.
  Future<T?> getPreference<T>(String key) async {
    try {
      final preferences = await getPreferences();
      final value = preferences[key];
      if (value == null) return null;
      return value as T?;
    } catch (e) {
      return null;
    }
  }

  /// Gets all user preferences.
  Future<Map<String, dynamic>> getPreferences() async {
    try {
      final prefs = await _prefs;
      final preferencesJson = prefs.getString(_userPreferencesKey);
      if (preferencesJson == null) return {};

      final preferencesMap = jsonDecode(preferencesJson) as Map<String, dynamic>;
      return preferencesMap;
    } catch (e) {
      return {};
    }
  }

  // ==================== General Operations ====================

  /// Clears all stored data (use with caution - for logout or reset).
  Future<bool> clearAll() async {
    try {
      final prefs = await _prefs;
      return await prefs.clear();
    } catch (e) {
      return false;
    }
  }

  /// Clears user-specific data (keeps app settings).
  Future<bool> clearUserData() async {
    try {
      final prefs = await _prefs;
      await prefs.remove(_cartKey);
      await prefs.remove(_favoritesKey);
      await prefs.remove(_recentlyViewedKey);
      await prefs.remove(_userIdKey);
      return true;
    } catch (e) {
      return false;
    }
  }
}

