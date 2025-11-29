import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/cart.dart';
import '../../models/live_event.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/live_event_provider.dart';
import '../../providers/socket_provider.dart';
import '../../widgets/common/footer.dart';
import '../../widgets/common/top_bar.dart';
import '../../widgets/live/cart_drawer.dart';
import '../../widgets/live/chat_widget.dart';
import '../../widgets/live/event_info_card.dart';
import '../../widgets/live/product_card.dart';
import '../../widgets/live/video_player_widget.dart';

class LiveEventScreen extends ConsumerStatefulWidget {
  const LiveEventScreen({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<LiveEventScreen> createState() => _LiveEventScreenState();
}

class _LiveEventScreenState extends ConsumerState<LiveEventScreen> {
  bool _isCartOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final socket = ref.read(mockSocketServiceProvider);
          socket.joinLiveEvent(widget.eventId);
        } catch (e) {
          debugPrint('Error joining live event: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    try {
      final socket = ref.read(mockSocketServiceProvider);
      socket.leaveLiveEvent(widget.eventId);
    } catch (e) {
      debugPrint('Error leaving live event: $e');
    }
    super.dispose();
  }

  void _toggleCart() {
    setState(() {
      _isCartOpen = !_isCartOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncEvent = ref.watch(liveEventByIdProvider(widget.eventId));
    final asyncProducts = ref.watch(eventProductsProvider(widget.eventId));
    final asyncCart = ref.watch(cartProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 1024;
    final isMedium = screenWidth >= 768 && screenWidth < 1024;

    return asyncEvent.when(
      loading: () => Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: const Center(
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: CustomScrollView(
          slivers: [
            const TopBar(),
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur de chargement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$e',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: const Footer(),
              ),
            ),
          ],
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

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  const TopBar(),
                  SliverToBoxAdapter(
                    child: isWide
                        ? _buildWideLayout(context, event, asyncProducts, cartItemCount)
                        : isMedium
                            ? _buildMediumLayout(context, event, asyncProducts, cartItemCount)
                            : _buildMobileLayout(context, event, asyncProducts, cartItemCount),
                  ),
                  const SliverToBoxAdapter(
                    child: Footer(),
                  ),
                ],
              ),
              if (_isCartOpen)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _toggleCart,
                    child: Container(
                      color: Colors.black.withOpacity(0.4),
                    ),
                  ),
                ),
              if (_isCartOpen)
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: isWide ? 420 : MediaQuery.of(context).size.width * 0.9,
                    child: Material(
                      elevation: 24,
                      shadowColor: Colors.black.withOpacity(0.3),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                      ),
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
    final screenHeight = MediaQuery.of(context).size.height;
    final topBarHeight = 80.0;
    final margins = 32.0;
    final availableHeight = screenHeight - topBarHeight - margins;

    return Container(
      constraints: const BoxConstraints(maxWidth: 1600),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Video player container
                _buildVideoPlayer(context, event),
                const SizedBox(height: 12),
                // Event info card
                EventInfoCard(event: event, isWide: true),
                const SizedBox(height: 12),
                // Chat container - allow it to grow but set a reasonable max
                Container(
                  constraints: BoxConstraints(
                    minHeight: 300,
                    maxHeight: availableHeight * 0.6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ChatWidget(socket: socket),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Products sidebar - this scrolls independently
          Expanded(
            flex: 3,
            child: SizedBox(
              height: availableHeight,
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 400,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _ProductsSidebar(
                  event: event,
                  asyncProducts: asyncProducts,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediumLayout(
    BuildContext context,
    LiveEvent event,
    AsyncValue<List<Product>> asyncProducts,
    int cartItemCount,
  ) {
    final socket = ref.watch(mockSocketServiceProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVideoPlayer(context, event),
          const SizedBox(height: 16),
          EventInfoCard(event: event, isWide: false),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: 500,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ChatWidget(socket: socket),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 500),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _ProductsSidebar(
                    event: event,
                    asyncProducts: asyncProducts,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    LiveEvent event,
    AsyncValue<List<Product>> asyncProducts,
    int cartItemCount,
  ) {
    final socket = ref.watch(mockSocketServiceProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildVideoPlayer(context, event),
          Container(
            margin: const EdgeInsets.all(16),
            child: EventInfoCard(event: event, isWide: false),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: DefaultTabController(
              length: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                    ),
                    child: TabBar(
                      indicatorColor: const Color(0xFF4A9FCC),
                      indicatorWeight: 3,
                      labelColor: const Color(0xFF4A9FCC),
                      unselectedLabelColor: Colors.grey[600],
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      tabs: const [
                        Tab(text: 'Produits'),
                        Tab(text: 'Chat'),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
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
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(BuildContext context, LiveEvent event) {
    final socket = ref.watch(mockSocketServiceProvider);
    final isLive = event.status == 'live';
    final isWide = MediaQuery.of(context).size.width >= 1024;

    String formatViewerCount(int count) {
      if (count >= 1000000) {
        return '${(count / 1000000).toStringAsFixed(1)}M';
      } else if (count >= 1000) {
        return '${(count / 1000).toStringAsFixed(1)}K';
      }
      return count.toString();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              VideoPlayerWidget(event: event),
              // Gradient overlay - ignore pointer so it doesn't block video controls
              IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                      ],
                      stops: const [0.0, 0.1, 0.9, 1.0],
                    ),
                  ),
                ),
              ),
              if (isLive) ...[
                // Live badge
                Positioned(
                  left: isWide ? 16 : 12,
                  top: isWide ? 16 : 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 14 : 10,
                      vertical: isWide ? 8 : 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(isWide ? 24 : 16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withOpacity(0.5),
                          blurRadius: isWide ? 12 : 8,
                          offset: Offset(0, isWide ? 4 : 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: isWide ? 10 : 6,
                          height: isWide ? 10 : 6,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.8),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: isWide ? 8 : 4),
                        Text(
                          'EN DIRECT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isWide ? 13 : 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: isWide ? 0.8 : 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Viewer count badge
                Positioned(
                  right: isWide ? 16 : 12,
                  top: isWide ? 16 : 12,
                  child: StreamBuilder<int>(
                    stream: socket.viewerCount,
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? event.viewerCount;
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 14 : 8,
                          vertical: isWide ? 8 : 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(isWide ? 0.7 : 0.6),
                          borderRadius: BorderRadius.circular(isWide ? 24 : 16),
                          border: isWide
                              ? Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.visibility,
                              size: isWide ? 16 : 14,
                              color: Colors.white,
                            ),
                            SizedBox(width: isWide ? 8 : 4),
                            Text(
                              isWide ? formatViewerCount(count) : '$count',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isWide ? 14 : 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
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
        child: CircularProgressIndicator(strokeWidth: 3),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Erreur produits',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
      data: (products) {
        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/no_image.svg',
                  width: 80,
                  height: 80,
                  colorFilter: ColorFilter.mode(
                    Colors.grey[400]!,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucun produit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        }

        final featuredProductId = event.featuredProduct;
        final featured = featuredProductId != null
            ? products.firstWhere(
                (p) => p.id == featuredProductId,
                orElse: () => products.first,
              )
            : products.first;

        // Filter out the featured product from the regular products list
        final regularProducts = featuredProductId != null
            ? products.where((p) => p.id != featuredProductId).toList()
            : products.skip(1).toList();

        final screenWidth = MediaQuery.of(context).size.width;
        final isSmall = screenWidth < 600;
        final padding = isSmall ? 12.0 : 20.0;

        return ListView(
          padding: EdgeInsets.all(padding),
          children: [
            ...[
              Container(
                padding: EdgeInsets.all(isSmall ? 8 : 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFF59E0B).withOpacity(0.1),
                      const Color(0xFFEAB308).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isSmall ? 4 : 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.star, color: Colors.white, size: isSmall ? 14 : 16),
                    ),
                    SizedBox(width: isSmall ? 6 : 10),
                    Flexible(
                      child: Text(
                        'PRODUIT VEDETTE',
                        style: TextStyle(
                          color: const Color(0xFFF59E0B),
                          fontSize: isSmall ? 11 : 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isSmall ? 12 : 16),
              ProductCard(product: featured, isFeatured: true),
              SizedBox(height: isSmall ? 16 : 24),
            ],
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmall ? 6 : 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A9FCC).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: const Color(0xFF4A9FCC),
                    size: isSmall ? 18 : 20,
                  ),
                ),
                SizedBox(width: isSmall ? 8 : 12),
                Flexible(
                  child: Text(
                    'Tous les produits',
                    style: TextStyle(
                      fontSize: isSmall ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmall ? 8 : 10,
                    vertical: isSmall ? 3 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A9FCC).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${regularProducts.length}',
                    style: TextStyle(
                      color: const Color(0xFF4A9FCC),
                      fontSize: isSmall ? 12 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmall ? 12 : 16),
            ...regularProducts.map(
              (p) => Padding(
                padding: EdgeInsets.only(bottom: isSmall ? 8 : 12),
                child: ProductCard(
                  product: p,
                  isFeatured: false,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
