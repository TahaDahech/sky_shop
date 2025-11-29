import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common/login_dialog.dart';
import '../../widgets/common/optimized_image.dart';

class ProductCard extends ConsumerWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.isFeatured = false,
  });

  final Product product;
  final bool isFeatured;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 600;
    final imageSize = isSmall ? 60.0 : 72.0;
    final padding = isSmall ? 6.0 : 8.0;

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isFeatured 
                ? const Color(0xFFF59E0B).withOpacity(0.3)
                : Colors.grey[200]!,
            width: isFeatured ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isFeatured ? 0.08 : 0.04),
              blurRadius: isFeatured ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RepaintBoundary(
                child: OptimizedImage(
                  imageUrl: product.thumbnail,
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(8),
                  errorIconSize: isSmall ? 24 : 32,
                ),
              ),
              SizedBox(width: isSmall ? 6 : 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF1E293B),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isFeatured)
                          Container(
                            margin: EdgeInsets.only(left: isSmall ? 2 : 4),
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmall ? 4 : 6,
                              vertical: isSmall ? 1 : 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFEAB308)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'VEDETTE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmall ? 8 : 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: isSmall ? 2 : 4),
                    Text(
                      product.category,
                      style: TextStyle(
                        fontSize: isSmall ? 11 : 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isSmall ? 4 : 6),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${product.salePrice ?? product.price}€',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4A9FCC),
                              fontSize: isSmall ? 14 : 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (product.salePrice != null)
                          Padding(
                            padding: EdgeInsets.only(left: isSmall ? 4 : 6),
                            child: Text(
                              '${product.price}€',
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                fontSize: isSmall ? 11 : 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: isSmall ? 6 : 8),
              SizedBox(
                height: isSmall ? 28 : 32,
                child: ElevatedButton(
                  onPressed: () async {
                    final isLoggedIn = ref.read(isLoggedInProvider);
                    
                    if (!isLoggedIn) {
                      // Show login dialog
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) => const LoginDialog(),
                      );
                      
                      if (result == true && context.mounted) {
                        // User logged in, add to cart after login
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
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A9FCC),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 10 : 14,
                      vertical: isSmall ? 6 : 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: TextStyle(
                      fontSize: isSmall ? 11 : 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Ajouter'),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}


