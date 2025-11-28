import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/live_event_provider.dart';

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
    final asyncCart = ref.watch(cartProvider);

    return asyncProduct.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Produit'),
        ),
        body: Center(
          child: Text('Erreur de chargement : $e'),
        ),
      ),
      data: (product) {
        final isWide = MediaQuery.of(context).size.width >= 800;
        final cartItemCount = asyncCart
            .maybeWhen(data: (cart) => cart.items.length, orElse: () => 0);

        return Scaffold(
          appBar: AppBar(
            title: Text(product.name),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Partage simulé.'),
                    ),
                  );
                },
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => context.go('/live/evt_001'),
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
          body: isWide
              ? Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildMainContent(context, product),
                    ),
                    Expanded(
                      flex: 2,
                      child: _buildRightColumn(
                        context,
                        product,
                        asyncAllProducts,
                      ),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMainContent(context, product),
                      const Divider(),
                      _buildRightColumn(
                        context,
                        product,
                        asyncAllProducts,
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context, Product product) {
    final images = product.images;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
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
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      images.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: _imageIndex == index ? 10 : 6,
                        height: _imageIndex == index ? 10 : 6,
                        decoration: BoxDecoration(
                          color: _imageIndex == index
                              ? Colors.white
                              : Colors.white54,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            product.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            product.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildRightColumn(
    BuildContext context,
    Product product,
    AsyncValue<List<Product>> asyncAllProducts,
  ) {
    final salePrice = product.salePrice ?? product.price;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$salePrice€',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (product.salePrice != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '${product.price}€',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          decoration: TextDecoration.lineThrough,
                        ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Stock disponible : ${product.stock}'),
          const SizedBox(height: 16),
          if (product.variations != null)
            _buildVariations(context, product.variations!),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final cartService = ref.read(cartServiceProvider);
                    await cartService.addToCart(product.id, 1);
                    ref.invalidate(cartProvider);
                  },
                  child: const Text('Ajouter au panier'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final cartService = ref.read(cartServiceProvider);
                    await cartService.addToCart(product.id, 1);
                    ref.invalidate(cartProvider);
                    // In a real app, you might go straight to checkout.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Achat immédiat simulé.'),
                      ),
                    );
                  },
                  child: const Text('Acheter maintenant'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Avis clients',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '⭐️⭐️⭐️⭐️☆  (${product.reviewsCount} avis)',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          const Text(
            '“Super qualité, taille bien. Je recommande !”',
          ),
          const SizedBox(height: 24),
          Text(
            'Produits similaires',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: asyncAllProducts.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Center(
                child: Text('Erreur : $e'),
              ),
              data: (all) {
                final similar = all
                    .where((p) =>
                        p.category == product.category &&
                        p.id != product.id)
                    .toList();
                if (similar.isEmpty) {
                  return const Center(
                    child: Text('Aucun produit similaire.'),
                  );
                }

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: similar.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final p = similar[index];
                    return GestureDetector(
                      onTap: () =>
                          context.go('/product/${p.id}'),
                      child: SizedBox(
                        width: 140,
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: p.thumbnail,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                key,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: values.map((value) {
                  final isSelected = value == selected;
                  return ChoiceChip(
                    label: Text(value),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedVariations[key] = value;
                      });
                    },
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

