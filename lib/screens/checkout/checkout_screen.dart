import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/cart.dart';
import '../../providers/cart_provider.dart';
import '../../providers/live_event_provider.dart';
import '../../providers/socket_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController(text: 'France');

  String _paymentMethod = 'card';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncCart = ref.watch(cartProvider);

    return asyncCart.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Center(child: Text('Erreur de chargement du panier : $e')),
      ),
      data: (Cart cart) {
        final subtotal = cart.items.fold<double>(
          0,
          (sum, item) => sum + item.quantity * 1.0,
        );
        const shipping = 5.99;
        final total = subtotal + shipping;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Checkout'),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 800;

              final summary = _buildSummary(context, cart, subtotal, shipping, total);
              final form = _buildForm(context);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Center(
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: form),
                              const SizedBox(width: 24),
                              Expanded(child: summary),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              summary,
                              const SizedBox(height: 24),
                              form,
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _onConfirm(context),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Confirmer la commande'),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummary(
    BuildContext context,
    Cart cart,
    double subtotal,
    double shipping,
    double total,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Récapitulatif',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...cart.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('Produit ${item.productId}'),
                    ),
                    Text('x${item.quantity}'),
                  ],
                ),
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sous-total'),
                Text('${subtotal.toStringAsFixed(2)}€'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Livraison'),
                Text('5.99€'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${total.toStringAsFixed(2)}€',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adresse de livraison',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Ville',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(
                  labelText: 'Code postal',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(
                  labelText: 'Pays',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              Text(
                'Mode de paiement',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              RadioListTile<String>(
                value: 'card',
                groupValue: _paymentMethod,
                onChanged: (val) {
                  setState(() {
                    _paymentMethod = val ?? 'card';
                  });
                },
                title: const Text('Carte bancaire'),
              ),
              RadioListTile<String>(
                value: 'paypal',
                groupValue: _paymentMethod,
                onChanged: (val) {
                  setState(() {
                    _paymentMethod = val ?? 'card';
                  });
                },
                title: const Text('PayPal'),
              ),
              RadioListTile<String>(
                value: 'cod',
                groupValue: _paymentMethod,
                onChanged: (val) {
                  setState(() {
                    _paymentMethod = val ?? 'card';
                  });
                },
                title: const Text('Paiement à la livraison'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onConfirm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simulate payment processing delay.
      await Future.delayed(const Duration(seconds: 2));

      final cartService = ref.read(cartServiceProvider);
      final order = await cartService.checkout();

      // Emit order via socket for real-time updates (if connected).
      final socket = ref.read(mockSocketServiceProvider);
      socket.emitNewOrder(order);

      // Refresh cart (it should now be empty after checkout).
      ref.invalidate(cartProvider);

      if (mounted) {
        context.go('/checkout/success');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du paiement : $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}


