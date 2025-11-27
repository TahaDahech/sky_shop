import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';

/// Provider exposing the authentication service and user state.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// TODO: Add another provider for the current authenticated user if needed.


