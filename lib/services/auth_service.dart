import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/app_user.dart';
import '../services/storage_service.dart';

/// Service to handle authentication (login, logout, token refresh, etc.).
class AuthService {
  AppUser? _currentUser;
  Map<String, dynamic>? _mockData;
  final StorageService _storageService;

  AuthService({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  /// Current authenticated user, or null if not logged in.
  AppUser? get currentUser => _currentUser;

  /// Whether a user is currently logged in.
  bool get isLoggedIn => _currentUser != null;

  /// Initializes the service by loading the user from SharedPreferences.
  /// Should be called on app startup.
  Future<void> initialize() async {
    final savedUser = await _storageService.loadUser();
    if (savedUser != null) {
      _currentUser = savedUser;
    }
  }

  /// Loads and caches the mock JSON data from assets.
  Future<void> _loadMockData() async {
    if (_mockData != null) return;

    try {
      final jsonString = await rootBundle.loadString('assets/mock-api-data.json');
      final decoded = json.decode(jsonString);
      if (decoded is Map<String, dynamic>) {
        _mockData = decoded;
      } else {
        throw Exception('Invalid JSON format: expected Map');
      }
    } catch (e) {
      throw Exception('Failed to load mock data: $e');
    }
  }

  /// Logs in a user with email and password.
  /// For mock purposes, any password works if the email exists in mock data.
  Future<bool> login(String email, String password) async {
    try {
      await _loadMockData();
      final usersJson = _mockData!['users'] as List<dynamic>;
      
      // Find user by email
      final userJson = usersJson.cast<Map<String, dynamic>>().firstWhere(
        (u) => (u['email'] as String).toLowerCase() == email.toLowerCase(),
        orElse: () => throw Exception('User not found'),
      );

      // For mock purposes, any password works
      _currentUser = AppUser.fromJson(userJson);
      
      // Save user to SharedPreferences
      await _storageService.saveUser(_currentUser!);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Logs out the current user.
  Future<void> logout() async {
    _currentUser = null;
    await _storageService.clearUser();
  }
}


