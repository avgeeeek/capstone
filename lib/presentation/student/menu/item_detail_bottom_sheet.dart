import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/models/vendor_model.dart';
import '../../../logic/providers/cart_provider.dart';
import '../../../core/constants/app_colors.dart';

class ItemDetailBottomSheet extends StatelessWidget {
  final MenuItemModel item;
  final VendorModel vendor;

  const ItemDetailBottomSheet({super.key, required this.item, required this.vendor});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final qty = cart.getItemQuantity(item.id);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: item.imageUrl != null
                          ? Image.network(
                              item.imageUrl!,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              height: 220,
                              color: AppColors.primaryLight,
                              child: const Center(
                                child: Icon(Icons.fastfood_rounded, color: AppColors.primary, size: 80),
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                              Text(
                                '₹${item.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Category badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.category,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (item.rating > 0) Row(
                            children: [
                              ...List.generate(5, (i) => Icon(
                                i < item.rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: const Color(0xFFFBBF24), size: 18,
                              )),
                              const SizedBox(width: 6),
                              Text(
                                item.rating.toStringAsFixed(1),
                                style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter'),
                              ),
                            ],
                          ),
                          if (item.description.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'Description',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Inter', color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                fontFamily: 'Inter',
                                height: 1.6,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          if (!item.isAvailable)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.errorLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.cancel_rounded, color: AppColors.error),
                                  SizedBox(width: 8),
                                  Text('This item is currently out of stock',
                                      style: TextStyle(color: AppColors.error, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          const SizedBox(height: 24),
                          // Add to cart
                          if (item.isAvailable)
                            qty == 0
                                ? SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        final success = cart.addItem(item, vendor.id, vendor.stallName, vendor.upiId);
                                        if (!success && context.mounted) {
                                          Navigator.pop(context);
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Replace Cart?'),
                                              content: Text('Your cart has items from ${cart.vendorName}. Replace?'),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep')),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(ctx);
                                                    cart.forceAddItem(item, vendor.id, vendor.stallName, vendor.upiId);
                                                  },
                                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                                  child: const Text('Replace', style: TextStyle(color: Colors.white)),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else if (success) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${item.name} added to cart'),
                                              backgroundColor: AppColors.success,
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.add_shopping_cart_rounded),
                                      label: const Text('Add to Cart'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _qtyBtn(Icons.remove_rounded, () => cart.decrement(item.id)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        child: Text('$qty', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                                      ),
                                      _qtyBtn(Icons.add_rounded, () => cart.increment(item.id), filled: true),
                                    ],
                                  ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap, {bool filled = false}) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : Colors.transparent,
        border: Border.all(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: filled ? Colors.white : AppColors.primary, size: 22),
    ),
  );
}
