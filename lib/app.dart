import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'config/theme_config.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/category/categories_screen.dart';
import 'screens/category/category_products_screen.dart';
import 'screens/checkout/checkout_screen.dart';
import 'screens/checkout/checkout_success_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/live/live_event_screen.dart';
import 'screens/notification/notifications_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/product/product_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/search/search_results_screen.dart';

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
        final eventId = state.pathParameters['id'];
        if (eventId == null || eventId.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text('ID d\'événement manquant'),
            ),
          );
        }
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
    GoRoute(
      path: '/categories',
      name: 'categories',
      builder: (context, state) => const CategoriesScreen(),
    ),
    GoRoute(
      path: '/category/:slug',
      name: 'categoryProducts',
      builder: (context, state) {
        final slug = state.pathParameters['slug']!;
        return CategoryProductsScreen(categorySlug: slug);
      },
    ),
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) {
        final query = state.uri.queryParameters['q'] ?? '';
        return SearchResultsScreen(query: query);
      },
    ),
    GoRoute(
      path: '/cart',
      name: 'cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/orders',
      name: 'orders',
      builder: (context, state) => const OrdersScreen(),
    ),
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


