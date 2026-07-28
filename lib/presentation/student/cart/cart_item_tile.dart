import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../logic/providers/cart_provider.dart';
import '../../../core/constants/app_colors.dart';

class CartItemTile extends StatelessWidget {
  final CartItem cartItem;

  const CartItemTile({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: cartItem.menuItem.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: cartItem.menuItem.imageUrl!,
                    width: 64, height: 64, fit: BoxFit.cover,
                    placeholder: (_, __) => _placeholder(),
                    errorWidget: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 12),
          // Name + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.menuItem.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary, fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${cartItem.menuItem.price.toStringAsFixed(0)} each',
                  style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: ₹${cartItem.itemTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: AppColors.primary, fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          // Quantity controls
          Column(
            children: [
              _buildQtyBtn(Icons.add_rounded, () => cart.increment(cartItem.menuItem.id), filled: true),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  '${cartItem.quantity}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
                ),
              ),
              _buildQtyBtn(
                cartItem.quantity <= 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
                () => cart.decrement(cartItem.menuItem.id),
                isDanger: cartItem.quantity <= 1,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap, {bool filled = false, bool isDanger = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: filled
              ? AppColors.primary
              : isDanger
                  ? AppColors.errorLight
                  : AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: filled ? Colors.white : isDanger ? AppColors.error : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 64, height: 64,
    color: AppColors.primaryLight,
    child: const Icon(Icons.fastfood_rounded, color: AppColors.primary, size: 28),
  );
}
