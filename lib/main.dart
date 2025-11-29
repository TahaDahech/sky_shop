import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'providers/auth_provider.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize auth service to load user from SharedPreferences
  final authService = AuthService();
  await authService.initialize();
  
  runApp(ProviderScope(
    overrides: [
      authServiceProvider.overrideWithValue(authService),
    ],
    child: const SkyShopApp(),
  ));
}
