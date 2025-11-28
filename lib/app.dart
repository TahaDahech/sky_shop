import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'config/theme_config.dart';
import 'screens/home/home_screen.dart';
import 'screens/live/live_event_screen.dart';
import 'screens/product/product_screen.dart';
import 'screens/checkout/checkout_screen.dart';
import 'screens/checkout/checkout_success_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/live/:id',
      name: 'liveEvent',
      builder: (context, state) {
        final eventId = state.pathParameters['id']!;
        return LiveEventScreen(eventId: eventId);
      },
    ),
    GoRoute(
      path: '/product/:id',
      name: 'productDetail',
      builder: (context, state) {
        final productId = state.pathParameters['id']!;
        return ProductDetailScreen(productId: productId);
      },
    ),
    GoRoute(
      path: '/checkout',
      name: 'checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/checkout/success',
      name: 'checkoutSuccess',
      builder: (context, state) => const CheckoutSuccessScreen(),
    ),
    // TODO: add more routes for profile, etc.
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


