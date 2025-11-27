import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'config/theme_config.dart';
import 'screens/home/home_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    // TODO: add more routes for live, product, profile, etc.
  ],
);

class SkyShopApp extends StatelessWidget {
  const SkyShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Sky Shop',
      theme: buildLightTheme(),
      routerConfig: appRouter,
    );
  }
}


