import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../models/cart.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/live_event.dart';
import '../models/notification.dart' as models;

/// Service for managing local storage using SharedPreferences.
/// Handles cart persistence and other user interactions.
class StorageService {
  static const String _cartKeyPrefix = 'cart_data_';
  static const String _ordersKeyPrefix = 'orders_';
  static const String _favoritesKey = 'favorite_products';
  static const String _recentlyViewedKey = 'recently_viewed_products';
  static const String _userIdKey = 'current_user_id';
  static const String _userDataKey = 'current_user_data';
  static const String _userPreferencesKey = 'user_preferences';
  
  // Offline cache keys
  static const String _cachedProductsKey = 'cached_products';
  static const String _cachedCategoriesKey = 'cached_categories';
  static const String _cachedLiveEventsKey = 'cached_live_events';
  static const String _cachedNotificationsKey = 'cached_notifications';
  static const String _cachedDataTimestampKey = 'cached_data_timestamp';
  
  // User-specific notification keys
  static const String _notificationsKeyPrefix = 'notifications_';
  static const String _notificationReadStatusKeyPrefix = 'notification_read_';

  /// Gets the SharedPreferences instance.
  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // ==================== User Operations ====================

  /// Saves the current user to local storage.
  Future<bool> saveUser(AppUser user) async {
    try {
      final prefs = await _prefs;
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(_userDataKey, userJson);
      return await prefs.setString(_userIdKey, user.id);
    } catch (e) {
      return false;
    }
  }

  /// Loads the current user from local storage.
  /// Returns null if no user is saved.
  Future<AppUser?> loadUser() async {
    try {
      final prefs = await _prefs;
      final userJson = prefs.getString(_userDataKey);
      if (userJson == null) return null;

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return AppUser.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  /// Clears the current user from local storage.
  Future<bool> clearUser() async {
    try {
      final prefs = await _prefs;
      await prefs.remove(_userDataKey);
      return await prefs.remove(_userIdKey);
    } catch (e) {
      return false;
    }
  }

  // ==================== Cart Operations ====================

  /// Saves the cart to local storage (user-specific).
  Future<bool> saveCart(Cart cart) async {
    try {
      final prefs = await _prefs;
      final cartKey = '$_cartKeyPrefix${cart.userId}';
      final cartJson = jsonEncode(cart.toJson());
      return await prefs.setString(cartKey, cartJson);
    } catch (e) {
      return false;
    }
  }

  /// Loads the cart from local storage for a specific user.
  /// Returns null if no cart is saved.
  Future<Cart?> loadCart(String userId) async {
    try {
      final prefs = await _prefs;
      final cartKey = '$_cartKeyPrefix$userId';
      final cartJson = prefs.getString(cartKey);
      if (cartJson == null) return null;

      final cartMap = jsonDecode(cartJson) as Map<String, dynamic>;
      return Cart.fromJson(cartMap);
    } catch (e) {
      return null;
    }
  }

  /// Clears the cart from local storage for a specific user.
  Future<bool> clearCart(String userId) async {
    try {
      final prefs = await _prefs;
      final cartKey = '$_cartKeyPrefix$userId';
      return await prefs.remove(cartKey);
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
      final userId = await getUserId();
      if (userId != null) {
        await clearCart(userId);
        await clearOrders(userId);
      }
      await prefs.remove(_favoritesKey);
      await prefs.remove(_recentlyViewedKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userDataKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== Orders Operations ====================

  /// Saves an order to local storage (user-specific).
  Future<bool> saveOrder(Order order) async {
    try {
      final orders = await loadOrders(order.userId);
      // Check if order already exists
      final existingIndex = orders.indexWhere((o) => o.id == order.id);
      if (existingIndex >= 0) {
        orders[existingIndex] = order;
      } else {
        orders.add(order);
      }
      return await _saveOrders(order.userId, orders);
    } catch (e) {
      return false;
    }
  }

  /// Loads all orders from local storage for a specific user.
  /// Returns empty list if no orders are saved.
  Future<List<Order>> loadOrders(String userId) async {
    try {
      final prefs = await _prefs;
      final ordersKey = '$_ordersKeyPrefix$userId';
      final ordersJson = prefs.getString(ordersKey);
      if (ordersJson == null) return [];

      final ordersList = jsonDecode(ordersJson) as List<dynamic>;
      return ordersList
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Saves a list of orders to local storage for a specific user.
  Future<bool> _saveOrders(String userId, List<Order> orders) async {
    try {
      final prefs = await _prefs;
      final ordersKey = '$_ordersKeyPrefix$userId';
      final ordersJson = jsonEncode(orders.map((o) => o.toJson()).toList());
      return await prefs.setString(ordersKey, ordersJson);
    } catch (e) {
      return false;
    }
  }

  /// Clears all orders from local storage for a specific user.
  Future<bool> clearOrders(String userId) async {
    try {
      final prefs = await _prefs;
      final ordersKey = '$_ordersKeyPrefix$userId';
      return await prefs.remove(ordersKey);
    } catch (e) {
      return false;
    }
  }

  // ==================== Offline Cache Operations ====================

  /// Saves products to offline cache.
  Future<bool> cacheProducts(List<Product> products) async {
    try {
      final prefs = await _prefs;
      final productsJson = jsonEncode(products.map((p) => p.toJson()).toList());
      await prefs.setString(_cachedProductsKey, productsJson);
      await prefs.setString(_cachedDataTimestampKey, DateTime.now().toIso8601String());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Loads products from offline cache.
  Future<List<Product>> loadCachedProducts() async {
    try {
      final prefs = await _prefs;
      final productsJson = prefs.getString(_cachedProductsKey);
      if (productsJson == null) return [];

      final productsList = jsonDecode(productsJson) as List<dynamic>;
      return productsList
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Saves categories to offline cache.
  Future<bool> cacheCategories(List<Category> categories) async {
    try {
      final prefs = await _prefs;
      final categoriesJson = jsonEncode(categories.map((c) => c.toJson()).toList());
      await prefs.setString(_cachedCategoriesKey, categoriesJson);
      await prefs.setString(_cachedDataTimestampKey, DateTime.now().toIso8601String());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Loads categories from offline cache.
  Future<List<Category>> loadCachedCategories() async {
    try {
      final prefs = await _prefs;
      final categoriesJson = prefs.getString(_cachedCategoriesKey);
      if (categoriesJson == null) return [];

      final categoriesList = jsonDecode(categoriesJson) as List<dynamic>;
      return categoriesList
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Saves live events to offline cache.
  Future<bool> cacheLiveEvents(List<LiveEvent> events) async {
    try {
      final prefs = await _prefs;
      final eventsJson = jsonEncode(events.map((e) => e.toJson()).toList());
      await prefs.setString(_cachedLiveEventsKey, eventsJson);
      await prefs.setString(_cachedDataTimestampKey, DateTime.now().toIso8601String());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Loads live events from offline cache.
  Future<List<LiveEvent>> loadCachedLiveEvents() async {
    try {
      final prefs = await _prefs;
      final eventsJson = prefs.getString(_cachedLiveEventsKey);
      if (eventsJson == null) return [];

      final eventsList = jsonDecode(eventsJson) as List<dynamic>;
      return eventsList
          .map((e) => LiveEvent.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Saves notifications to offline cache.
  Future<bool> cacheNotifications(List<models.AppNotification> notifications) async {
    try {
      final prefs = await _prefs;
      final notificationsJson = jsonEncode(notifications.map((n) => n.toJson()).toList());
      await prefs.setString(_cachedNotificationsKey, notificationsJson);
      await prefs.setString(_cachedDataTimestampKey, DateTime.now().toIso8601String());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Loads notifications from offline cache.
  Future<List<models.AppNotification>> loadCachedNotifications() async {
    try {
      final prefs = await _prefs;
      final notificationsJson = prefs.getString(_cachedNotificationsKey);
      if (notificationsJson == null) return [];

      final notificationsList = jsonDecode(notificationsJson) as List<dynamic>;
      return notificationsList
          .map((e) => models.AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Checks if cached data exists.
  Future<bool> hasCachedData() async {
    try {
      final prefs = await _prefs;
      final timestamp = prefs.getString(_cachedDataTimestampKey);
      return timestamp != null && timestamp.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Gets the timestamp of when data was last cached.
  Future<DateTime?> getCachedDataTimestamp() async {
    try {
      final prefs = await _prefs;
      final timestampStr = prefs.getString(_cachedDataTimestampKey);
      if (timestampStr == null) return null;
      return DateTime.parse(timestampStr);
    } catch (e) {
      return null;
    }
  }

  /// Clears all cached API data.
  Future<bool> clearCachedData() async {
    try {
      final prefs = await _prefs;
      await prefs.remove(_cachedProductsKey);
      await prefs.remove(_cachedCategoriesKey);
      await prefs.remove(_cachedLiveEventsKey);
      await prefs.remove(_cachedNotificationsKey);
      await prefs.remove(_cachedDataTimestampKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== User-Specific Notification Operations ====================

  /// Saves notifications for a specific user.
  Future<bool> saveUserNotifications(String userId, List<models.AppNotification> notifications) async {
    try {
      final prefs = await _prefs;
      final notificationsKey = '$_notificationsKeyPrefix$userId';
      final notificationsJson = jsonEncode(notifications.map((n) => n.toJson()).toList());
      return await prefs.setString(notificationsKey, notificationsJson);
    } catch (e) {
      return false;
    }
  }

  /// Loads notifications for a specific user.
  Future<List<models.AppNotification>> loadUserNotifications(String userId) async {
    try {
      final prefs = await _prefs;
      final notificationsKey = '$_notificationsKeyPrefix$userId';
      final notificationsJson = prefs.getString(notificationsKey);
      if (notificationsJson == null) return [];

      final notificationsList = jsonDecode(notificationsJson) as List<dynamic>;
      final notifications = notificationsList
          .map((e) => models.AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
      
      // Apply persisted read status
      return await _applyPersistedReadStatus(userId, notifications);
    } catch (e) {
      return [];
    }
  }

  /// Deletes a notification for a specific user.
  Future<bool> deleteUserNotification(String userId, String notificationId) async {
    try {
      final notifications = await loadUserNotifications(userId);
      notifications.removeWhere((n) => n.id == notificationId);
      return await saveUserNotifications(userId, notifications);
    } catch (e) {
      return false;
    }
  }

  /// Deletes all notifications for a specific user.
  Future<bool> clearUserNotifications(String userId) async {
    try {
      final prefs = await _prefs;
      final notificationsKey = '$_notificationsKeyPrefix$userId';
      return await prefs.remove(notificationsKey);
    } catch (e) {
      return false;
    }
  }

  /// Marks a notification as read for a specific user (persists read status).
  Future<bool> markNotificationAsRead(String userId, String notificationId) async {
    try {
      final prefs = await _prefs;
      final readStatusKey = '$_notificationReadStatusKeyPrefix$userId';
      
      // Load existing read statuses
      final readStatusJson = prefs.getString(readStatusKey);
      final readStatuses = readStatusJson != null
          ? (jsonDecode(readStatusJson) as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, v as bool))
          : <String, bool>{};
      
      // Mark as read
      readStatuses[notificationId] = true;
      
      // Save back
      final updatedJson = jsonEncode(readStatuses);
      return await prefs.setString(readStatusKey, updatedJson);
    } catch (e) {
      return false;
    }
  }

  /// Marks all notifications as read for a specific user.
  Future<bool> markAllNotificationsAsRead(String userId, List<String> notificationIds) async {
    try {
      final prefs = await _prefs;
      final readStatusKey = '$_notificationReadStatusKeyPrefix$userId';
      
      // Load existing read statuses
      final readStatusJson = prefs.getString(readStatusKey);
      final readStatuses = readStatusJson != null
          ? (jsonDecode(readStatusJson) as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, v as bool))
          : <String, bool>{};
      
      // Mark all as read
      for (final id in notificationIds) {
        readStatuses[id] = true;
      }
      
      // Save back
      final updatedJson = jsonEncode(readStatuses);
      return await prefs.setString(readStatusKey, updatedJson);
    } catch (e) {
      return false;
    }
  }

  /// Applies persisted read status to notifications.
  Future<List<models.AppNotification>> _applyPersistedReadStatus(
    String userId,
    List<models.AppNotification> notifications,
  ) async {
    try {
      final prefs = await _prefs;
      final readStatusKey = '$_notificationReadStatusKeyPrefix$userId';
      final readStatusJson = prefs.getString(readStatusKey);
      
      if (readStatusJson == null) return notifications;
      
      final readStatuses = (jsonDecode(readStatusJson) as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v as bool));
      
      // Apply read status from storage
      return notifications.map((notification) {
        final isRead = readStatuses[notification.id] ?? notification.read;
        return models.AppNotification(
          id: notification.id,
          userId: notification.userId,
          type: notification.type,
          title: notification.title,
          message: notification.message,
          read: isRead,
          createdAt: notification.createdAt,
        );
      }).toList();
    } catch (e) {
      return notifications;
    }
  }

  /// Gets the read status for a notification.
  Future<bool> isNotificationRead(String userId, String notificationId) async {
    try {
      final prefs = await _prefs;
      final readStatusKey = '$_notificationReadStatusKeyPrefix$userId';
      final readStatusJson = prefs.getString(readStatusKey);
      
      if (readStatusJson == null) return false;
      
      final readStatuses = (jsonDecode(readStatusJson) as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v as bool));
      
      return readStatuses[notificationId] ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Clears read status for a specific user (useful for testing or reset).
  Future<bool> clearNotificationReadStatus(String userId) async {
    try {
      final prefs = await _prefs;
      final readStatusKey = '$_notificationReadStatusKeyPrefix$userId';
      return await prefs.remove(readStatusKey);
    } catch (e) {
      return false;
    }
  }
}

