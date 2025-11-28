import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/cart.dart';
import '../../models/live_event.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/live_event_provider.dart';
import '../../providers/socket_provider.dart';
import '../../widgets/live/cart_drawer.dart';
import '../../widgets/live/chat_widget.dart';
import '../../widgets/live/product_card.dart';
import '../../widgets/live/video_player_widget.dart';

class LiveEventScreen extends ConsumerStatefulWidget {
  const LiveEventScreen({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<LiveEventScreen> createState() =>
      _LiveEventScreenState();
}

class _LiveEventScreenState extends ConsumerState<LiveEventScreen> {
  bool _isCartOpen = false;

  @override
  void initState() {
    super.initState();
    final socket = ref.read(mockSocketServiceProvider);
    socket.joinLiveEvent(widget.eventId);
  }

  @override
  void dispose() {
    final socket = ref.read(mockSocketServiceProvider);
    socket.leaveLiveEvent(widget.eventId);
    super.dispose();
  }

  void _toggleCart() {
    setState(() {
      _isCartOpen = !_isCartOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncEvent =
        ref.watch(liveEventByIdProvider(widget.eventId));
    final asyncProducts =
        ref.watch(eventProductsProvider(widget.eventId));
    final asyncCart = ref.watch(cartProvider);
    final isWide = MediaQuery.of(context).size.width >= 900;

    return asyncEvent.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Événement en direct'),
        ),
        body: Center(
          child: Text('Erreur de chargement : $e'),
        ),
      ),
      data: (event) {
        final cartItemCount = asyncCart.maybeWhen(
          data: (Cart cart) => cart.items.fold<int>(
            0,
            (sum, item) => sum + item.quantity,
          ),
          orElse: () => 0,
        );

        final body = isWide
            ? _buildWideLayout(context, event, asyncProducts, cartItemCount)
            : _buildMobileLayout(
                context,
                event,
                asyncProducts,
                cartItemCount,
              );

        return Scaffold(
          appBar: AppBar(
            title: Text(event.title),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            actions: [
              StreamBuilder<int>(
                stream: ref
                    .watch(mockSocketServiceProvider)
                    .viewerCount,
                builder: (context, snapshot) {
                  final count =
                      snapshot.data ?? event.viewerCount;
                  return Row(
                    children: [
                      const Icon(Icons.remove_red_eye, size: 18),
                      const SizedBox(width: 4),
                      Text('$count'),
                      const SizedBox(width: 16),
                    ],
                  );
                },
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: _toggleCart,
                  ),
                  if (cartItemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$cartItemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: Stack(
            children: [
              body,
              if (_isCartOpen)
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width:
                        isWide ? 360 : MediaQuery.of(context).size.width,
                    child: Material(
                      elevation: 12,
                      child: CartDrawer(onClose: _toggleCart),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWideLayout(
    BuildContext context,
    LiveEvent event,
    AsyncValue<List<Product>> asyncProducts,
    int cartItemCount,
  ) {
    final socket = ref.watch(mockSocketServiceProvider);

    return Row(
      children: [
        // Left: video + chat
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: VideoPlayerWidget(event: event),
              ),
              Expanded(
                flex: 2,
                child: ChatWidget(
                  socket: socket,
                ),
              ),
            ],
          ),
        ),
        // Right: products sidebar
        Expanded(
          flex: 2,
          child: _ProductsSidebar(
            event: event,
            asyncProducts: asyncProducts,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    LiveEvent event,
    AsyncValue<List<Product>> asyncProducts,
    int cartItemCount,
  ) {
    final socket = ref.watch(mockSocketServiceProvider);

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: VideoPlayerWidget(event: event),
        ),
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Produits'),
                    Tab(text: 'Chat'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _ProductsSidebar(
                        event: event,
                        asyncProducts: asyncProducts,
                      ),
                      ChatWidget(socket: socket),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductsSidebar extends ConsumerWidget {
  const _ProductsSidebar({
    required this.event,
    required this.asyncProducts,
  });

  final LiveEvent event;
  final AsyncValue<List<Product>> asyncProducts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return asyncProducts.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (e, _) => Center(
        child: Text('Erreur produits : $e'),
      ),
      data: (products) {
        final featuredProductId = event.featuredProduct;
        final featured = featuredProductId != null
            ? products
                .firstWhere((p) => p.id == featuredProductId,
                    orElse: () => products.first)
            : products.isNotEmpty
                ? products.first
                : null;

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (featured != null)
              ProductCard(
                product: featured,
                isFeatured: true,
              ),
            const SizedBox(height: 12),
            Text(
              'Tous les produits',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...products.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ProductCard(
                  product: p,
                  isFeatured: p.id == featuredProductId,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}


