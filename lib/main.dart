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

  // Preload critical assets used in TopBar (shown on every screen)
  // This improves initial render performance
  await _preloadCriticalAssets();

  runApp(
    ProviderScope(
      overrides: [authServiceProvider.overrideWithValue(authService)],
      child: const SkyShopApp(),
    ),
  );
}

Future<void> _preloadCriticalAssets() async {
  // Critical assets used in TopBar (shown on every screen):
  // - assets/images/sky.svg
  // note from dev that  svgs are being preloaded in the svg package itself when the app starts
}
