import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'config/theme_config.dart';
import 'utils/lazy_loader.dart';
import 'widgets/common/app_wrapper.dart';
// Home screen is loaded eagerly as it's the initial route
import 'screens/home/home_screen.dart';

// Lazy loading for all other screens - code splitting
import 'screens/cart/cart_screen.dart' deferred as cart_screen;
import 'screens/category/categories_screen.dart' deferred as categories_screen;
import 'screens/category/category_products_screen.dart' deferred as category_products_screen;
import 'screens/checkout/checkout_screen.dart' deferred as checkout_screen;
import 'screens/checkout/checkout_success_screen.dart' deferred as checkout_success_screen;
import 'screens/live/live_event_screen.dart' deferred as live_event_screen;
import 'screens/notification/notifications_screen.dart' deferred as notifications_screen;
import 'screens/orders/orders_screen.dart' deferred as orders_screen;
import 'screens/product/product_screen.dart' deferred as product_screen;
import 'screens/profile/profile_screen.dart' deferred as profile_screen;
import 'screens/search/search_results_screen.dart' deferred as search_results_screen;

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
        return LazyLoader(
          loadLibrary: live_event_screen.loadLibrary,
          buildWidget: () => live_event_screen.LiveEventScreen(eventId: eventId),
        );
      },
    ),
    GoRoute(
      path: '/product/:id',
      name: 'productDetail',
      builder: (context, state) {
        final productId = state.pathParameters['id']!;
        return LazyLoader(
          loadLibrary: product_screen.loadLibrary,
          buildWidget: () => product_screen.ProductDetailScreen(productId: productId),
        );
      },
    ),
    GoRoute(
      path: '/checkout',
      name: 'checkout',
      builder: (context, state) => LazyLoader(
        loadLibrary: checkout_screen.loadLibrary,
        buildWidget: () => checkout_screen.CheckoutScreen(),
      ),
    ),
    GoRoute(
      path: '/checkout/success',
      name: 'checkoutSuccess',
      builder: (context, state) => LazyLoader(
        loadLibrary: checkout_success_screen.loadLibrary,
        buildWidget: () => checkout_success_screen.CheckoutSuccessScreen(),
      ),
    ),
    GoRoute(
      path: '/categories',
      name: 'categories',
      builder: (context, state) => LazyLoader(
        loadLibrary: categories_screen.loadLibrary,
        buildWidget: () => categories_screen.CategoriesScreen(),
      ),
    ),
    GoRoute(
      path: '/category/:slug',
      name: 'categoryProducts',
      builder: (context, state) {
        final slug = state.pathParameters['slug']!;
        return LazyLoader(
          loadLibrary: category_products_screen.loadLibrary,
          buildWidget: () => category_products_screen.CategoryProductsScreen(categorySlug: slug),
        );
      },
    ),
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) {
        final query = state.uri.queryParameters['q'] ?? '';
        return LazyLoader(
          loadLibrary: search_results_screen.loadLibrary,
          buildWidget: () => search_results_screen.SearchResultsScreen(query: query),
        );
      },
    ),
    GoRoute(
      path: '/cart',
      name: 'cart',
      builder: (context, state) => LazyLoader(
        loadLibrary: cart_screen.loadLibrary,
        buildWidget: () => cart_screen.CartScreen(),
      ),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => LazyLoader(
        loadLibrary: notifications_screen.loadLibrary,
        buildWidget: () => notifications_screen.NotificationsScreen(),
      ),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => LazyLoader(
        loadLibrary: profile_screen.loadLibrary,
        buildWidget: () => profile_screen.ProfileScreen(),
      ),
    ),
    GoRoute(
      path: '/orders',
      name: 'orders',
      builder: (context, state) => LazyLoader(
        loadLibrary: orders_screen.loadLibrary,
        buildWidget: () => orders_screen.OrdersScreen(),
      ),
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
      builder: (context, child) {
        return AppWrapper(child: child ?? const SizedBox.shrink());
      },
    );
  }
}


