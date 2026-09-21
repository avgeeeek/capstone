import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/helpers.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;
  final bool isSmall;

  const OrderStatusBadge({super.key, required this.status, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    final color = Helpers.getStatusColor(status);
    final label = Helpers.getStatusLabel(status);
    final icon = Helpers.getStatusIcon(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmall ? 12 : 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: isSmall ? 10 : 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentBadge extends StatelessWidget {
  final String method;
  final String status;

  const PaymentBadge({super.key, required this.method, required this.status});

  @override
  Widget build(BuildContext context) {
    final isGpay = method == 'gpay';
    final isPaid = status == 'paid';
    final color = isPaid ? AppColors.success : AppColors.warning;
    final label = isGpay
        ? (isPaid ? 'GPay Paid' : 'GPay Pending')
        : 'Cash Payment';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGpay ? Icons.payment_rounded : Icons.money_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
