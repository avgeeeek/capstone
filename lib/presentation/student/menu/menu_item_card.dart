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
    final isUnavailable = !item.isAvailable || item.isOutOfStock;

    return GestureDetector(
      onTap: isUnavailable ? null : onTap,
      child: Opacity(
        opacity: isUnavailable ? 0.55 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3)),
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
                          child: Center(
                            child: Text(
                              item.isOutOfStock ? 'Out of\nStock' : 'Unavailable',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
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
                          if (!isUnavailable)
                            _buildQuantityControl(context, cart, qty)
                          else if (item.isOutOfStock)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEDED),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Sold out',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.error,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                        ],
                      ),
                      // Stock display
                      if (!isUnavailable)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(
                                (item.stockCount ?? 0) <= 5
                                    ? Icons.warning_amber_rounded
                                    : Icons.inventory_2_rounded,
                                size: 11,
                                color: (item.stockCount ?? 0) <= 5
                                    ? AppColors.warning
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                (item.stockCount ?? 0) <= 5
                                    ? 'Only ${item.stockCount ?? 0} left!'
                                    : '${item.stockCount ?? 0} in stock',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: (item.stockCount ?? 0) <= 5
                                      ? AppColors.warning
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (item.isOutOfStock)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(Icons.cancel_rounded, size: 11, color: AppColors.error),
                              SizedBox(width: 3),
                              Text(
                                'Out of stock (0 left)',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Inter',
                                ),
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
      ),
    );
  }

  Widget _buildQuantityControl(BuildContext context, CartProvider cart, int qty) {
    // Cap additions to available stock
    final maxQty = item.hasStockTracking ? item.stockCount! : 99;

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
          onTap: qty >= maxQty ? null : () => _addToCart(context, cart),
          child: Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              color: qty >= maxQty ? AppColors.border : AppColors.primary,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(
              Icons.add_rounded,
              color: qty >= maxQty ? AppColors.textHint : Colors.white,
              size: 16,
            ),
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
