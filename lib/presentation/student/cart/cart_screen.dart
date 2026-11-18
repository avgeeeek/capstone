import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../logic/providers/cart_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import 'cart_item_tile.dart';
import 'cart_summary.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart ${cart.isEmpty ? '' : '(${cart.itemCount} items)'}'),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, cart),
              child: const Text('Clear', style: TextStyle(color: AppColors.error, fontFamily: 'Inter')),
            ),
        ],
      ),
      body: cart.isEmpty
          ? EmptyState(
              title: 'Your cart is empty',
              subtitle: 'Add some delicious food from a stall',
              icon: Icons.shopping_cart_outlined,
              action: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Browse Stalls'),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (_, i) => CartItemTile(cartItem: cart.items[i]),
                  ),
                ),
                // Summary + checkout
                CartSummary(cart: cart),
              ],
            ),
    );
  }

  void _confirmClear(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: const Text('Are you sure you want to remove all items?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              cart.clearCart();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
