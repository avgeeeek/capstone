import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/models/vendor_model.dart';
import '../../../logic/providers/cart_provider.dart';
import '../../../core/constants/app_colors.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItemModel item;
  final VendorModel vendor;
  final VoidCallback? onTap;

  const MenuItemCard({super.key, required this.item, required this.vendor, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final qty = cart.getItemQuantity(item.id);
    final isUnavailable = !item.isAvailable;

    return GestureDetector(
      onTap: isUnavailable ? null : onTap,
      child: Opacity(
        opacity: isUnavailable ? 0.55 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: item.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: item.imageUrl!,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _imagePlaceholder(),
                            errorWidget: (_, __, ___) => _imagePlaceholder(),
                          )
                        : _imagePlaceholder(),
                  ),
                  if (isUnavailable)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Container(
                          color: Colors.black38,
                          child: const Center(
                            child: Text(
                              'Out of\nStock',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (item.rating > 0)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 11, color: Color(0xFFFBBF24)),
                            const SizedBox(width: 2),
                            Text(item.rating.toStringAsFixed(1),
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${item.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              fontFamily: 'Inter',
                            ),
                          ),
                          if (!isUnavailable) _buildQuantityControl(context, cart, qty),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityControl(BuildContext context, CartProvider cart, int qty) {
    if (qty == 0) {
      return GestureDetector(
        onTap: () => _addToCart(context, cart),
        child: Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => cart.decrement(item.id),
          child: Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(Icons.remove_rounded, color: AppColors.primary, size: 16),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '$qty',
            style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary, fontFamily: 'Inter',
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _addToCart(context, cart),
          child: Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 16),
          ),
        ),
      ],
    );
  }

  void _addToCart(BuildContext context, CartProvider cart) {
    final success = cart.addItem(item, vendor.id, vendor.stallName, vendor.upiId);
    if (!success) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Replace Cart?'),
          content: Text('Your cart has items from ${cart.vendorName}. Replace with items from ${vendor.stallName}?'),
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
    }
  }

  Widget _imagePlaceholder() => Container(
    height: 120, width: double.infinity,
    color: AppColors.primaryLight,
    child: const Center(child: Icon(Icons.fastfood_rounded, color: AppColors.primary, size: 40)),
  );
}
