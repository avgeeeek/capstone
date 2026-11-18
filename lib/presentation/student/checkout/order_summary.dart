import 'package:flutter/material.dart';
import '../../../logic/providers/cart_provider.dart';
import '../../../core/constants/app_colors.dart';

class OrderSummaryWidget extends StatelessWidget {
  final CartProvider cart;

  const OrderSummaryWidget({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                cart.vendorName ?? 'Stall',
                style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: AppColors.primary, fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          ...cart.items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: AppColors.primary, fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.menuItem.name,
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontFamily: 'Inter'),
                  ),
                ),
                Text(
                  '₹${item.itemTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary, fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          )),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
              Text(
                '₹${cart.total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary, fontFamily: 'Inter'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
