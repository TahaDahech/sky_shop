import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

/// Provider exposing the authentication service.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for the current authenticated user.
/// Returns null if no user is logged in.
/// This provider watches the auth service and will update when invalidated.
final currentUserProvider = Provider<AppUser?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUser;
});

/// Provider indicating whether a user is logged in.
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});


