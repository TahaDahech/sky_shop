import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/cart.dart';
import '../../providers/cart_provider.dart';

class CartDrawer extends ConsumerWidget {
  const CartDrawer({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCart = ref.watch(cartProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Panier',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          Expanded(
            child: asyncCart.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Center(
                child: Text('Erreur panier : $e'),
              ),
              data: (Cart cart) {
                if (cart.items.isEmpty) {
                  return const Center(
                    child: Text('Votre panier est vide'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Produit ${item.productId}'),
                      subtitle: Text('Quantité : ${item.quantity}'),
                      trailing: TextButton(
                        onPressed: () {
                          // TODO: implement quantity modification/removal.
                        },
                        child: const Text('Modifier'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  onClose();
                  context.go('/checkout');
                },
                child: const Text('Checkout'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


