import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/live_event_provider.dart';
import '../../widgets/common/login_dialog.dart';
import '../../widgets/common/top_bar.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState
    extends ConsumerState<ProductDetailScreen> {
  int _imageIndex = 0;
  final Map<String, String> _selectedVariations = {};

  @override
  Widget build(BuildContext context) {
    final asyncProduct =
        ref.watch(productByIdProvider(widget.productId));
    final asyncAllProducts = ref.watch(allProductsProvider);

    return asyncProduct.when(
      loading: () => Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: CustomScrollView(
          slivers: [
            const TopBar(),
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Color(0xFF4A9FCC),
                ),
              ),
            ),
          ],
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
          ],
        ),
      ),
      data: (product) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isWide = screenWidth >= 800;

            return Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              body: CustomScrollView(
                slivers: [
                  const TopBar(),
                  SliverToBoxAdapter(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      margin: EdgeInsets.symmetric(
                        horizontal: isWide ? 24 : 16,
                        vertical: isWide ? 24 : 16,
                      ),
                      child: isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _buildMainContent(
                                    context,
                                    product,
                                    isWide: isWide,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 2,
                                  child: _buildRightColumn(
                                    context,
                                    product,
                                    asyncAllProducts,
                                    isWide: isWide,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildMainContent(
                                  context,
                                  product,
                                  isWide: isWide,
                                ),
                                const SizedBox(height: 24),
                                _buildRightColumn(
                                  context,
                                  product,
                                  asyncAllProducts,
                                  isWide: isWide,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    Product product, {
    required bool isWide,
  }) {
    final images = product.images;

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Gallery
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _imageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final url = images[index];
                      return Hero(
                        tag: 'product_${product.id}_image_$index',
                        child: CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/images/no_image.svg',
                                width: 64,
                                height: 64,
                                colorFilter: ColorFilter.mode(
                                  Colors.grey[400]!,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Image indicators
                  if (images.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _imageIndex == index ? 32 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _imageIndex == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Product Info
          Padding(
            padding: EdgeInsets.all(isWide ? 32 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  product.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightColumn(
    BuildContext context,
    Product product,
    AsyncValue<List<Product>> asyncAllProducts, {
    required bool isWide,
  }) {
    final salePrice = product.salePrice ?? product.price;
    final isOnSale = product.salePrice != null;

    return Container(
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
      child: Padding(
        padding: EdgeInsets.all(isWide ? 32 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$salePrice€',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A9FCC),
                  ),
                ),
                if (isOnSale) ...[
                  const SizedBox(width: 12),
                  Text(
                    '${product.price}€',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[500],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '-${((1 - salePrice / product.price) * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            // Stock
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: product.stock > 0
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    product.stock > 0 ? Icons.check_circle : Icons.cancel,
                    color: product.stock > 0
                        ? const Color(0xFF10B981)
                        : Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  product.stock > 0
                      ? 'En stock (${product.stock} disponibles)'
                      : 'Rupture de stock',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: product.stock > 0
                        ? const Color(0xFF10B981)
                        : Colors.red,
                  ),
                ),
              ],
            ),
            // Variations
            if (product.variations != null) ...[
              const SizedBox(height: 24),
              _buildVariations(context, product.variations!),
            ],
            const SizedBox(height: 32),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: product.stock > 0
                        ? () async {
                            final isLoggedIn = ref.read(isLoggedInProvider);
                            
                            if (!isLoggedIn) {
                              // Show login dialog
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (context) => const LoginDialog(),
                              );
                              
                              if (result == true && context.mounted) {
                                // User logged in, refresh the UI
                                ref.invalidate(currentUserProvider);
                                // Add to cart after login
                                final cartService = ref.read(cartServiceProvider);
                                await cartService.addToCart(product.id, 1);
                                ref.invalidate(cartProvider);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Produit ajouté au panier'),
                                      backgroundColor: const Color(0xFF4A9FCC),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              }
                            } else {
                              // User is logged in, add to cart
                              final cartService = ref.read(cartServiceProvider);
                              await cartService.addToCart(product.id, 1);
                              ref.invalidate(cartProvider);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Produit ajouté au panier'),
                                    backgroundColor: const Color(0xFF4A9FCC),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        : null,
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text(
                      'Ajouter au panier',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A9FCC),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: product.stock > 0
                        ? () async {
                            final isLoggedIn = ref.read(isLoggedInProvider);
                            
                            if (!isLoggedIn) {
                              // Show login dialog
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (context) => const LoginDialog(),
                              );
                              
                              if (result == true && context.mounted) {
                                // User logged in, refresh the UI
                                ref.invalidate(currentUserProvider);
                                // Add to cart after login
                                final cartService = ref.read(cartServiceProvider);
                                await cartService.addToCart(product.id, 1);
                                ref.invalidate(cartProvider);
                                if (context.mounted) {
                                  context.go('/cart');
                                }
                              }
                            } else {
                              // User is logged in, add to cart and navigate
                              final cartService = ref.read(cartServiceProvider);
                              await cartService.addToCart(product.id, 1);
                              ref.invalidate(cartProvider);
                              if (context.mounted) {
                                context.go('/cart');
                              }
                            }
                          }
                        : null,
                    icon: const Icon(Icons.flash_on),
                    label: const Text(
                      'Acheter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF4A9FCC),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFF4A9FCC),
                          width: 2,
                        ),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Reviews
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          size: 20,
                          color: index < 4
                              ? const Color(0xFFF59E0B)
                              : Colors.grey[300],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${product.reviewsCount} avis)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '"Super qualité, taille bien. Je recommande !"',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Similar Products
            Text(
              'Produits similaires',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: asyncAllProducts.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Color(0xFF4A9FCC),
                  ),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Erreur : $e',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                data: (all) {
                  final similar = all
                      .where((p) =>
                          p.category == product.category &&
                          p.id != product.id)
                      .take(5)
                      .toList();
                  if (similar.isEmpty) {
                    return Center(
                      child: Text(
                        'Aucun produit similaire.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }

                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: similar.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final p = similar[index];
                      final pSalePrice = p.salePrice ?? p.price;
                      return GestureDetector(
                        onTap: () => context.go('/product/${p.id}'),
                        child: Container(
                          width: 180,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: p.thumbnail,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                      ),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          'assets/images/no_image.svg',
                                          width: 40,
                                          height: 40,
                                          colorFilter: ColorFilter.mode(
                                            Colors.grey[400]!,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          '$pSalePrice€',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF4A9FCC),
                                          ),
                                        ),
                                        if (p.salePrice != null) ...[
                                          const SizedBox(width: 6),
                                          Text(
                                            '${p.price}€',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariations(
    BuildContext context,
    ProductVariations variations,
  ) {
    final chips = <Widget>[];

    variations.options.forEach((key, values) {
      final selected = _selectedVariations[key];
      chips.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                key,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: values.map((value) {
                  final isSelected = value == selected;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedVariations[key] = value;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF4A9FCC)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF4A9FCC)
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF4A9FCC).withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    });

    return Column(children: chips);
  }
}

