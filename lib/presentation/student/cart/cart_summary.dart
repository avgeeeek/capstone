import 'package:flutter/material.dart';
import '../../../logic/providers/cart_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';

class CartSummary extends StatelessWidget {
  final CartProvider cart;

  const CartSummary({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Vendor name
          Row(
            children: [
              const Icon(Icons.storefront_rounded, size: 16, color: AppColors.textHint),
              const SizedBox(width: 6),
              Text(
                cart.vendorName ?? '',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Inter'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 10),
          _row('Subtotal', '₹${cart.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 6),
          _row('Taxes & Fees', 'Included', valueColor: AppColors.textHint),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          _row(
            'Total',
            '₹${cart.total.toStringAsFixed(2)}',
            isBold: true,
            valueColor: AppColors.primary,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.checkout),
              icon: const Icon(Icons.payment_rounded),
              label: const Text('Proceed to Checkout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: valueColor ?? AppColors.textPrimary,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}
