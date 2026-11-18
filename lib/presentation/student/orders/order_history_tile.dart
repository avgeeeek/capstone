import 'package:flutter/material.dart';
import '../../../data/models/order_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/order_status_badge.dart';

class OrderHistoryTile extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderHistoryTile({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
          border: order.isActive
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5)
              : Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Status icon circle
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: _statusColor(order.status).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _statusIcon(order.status),
                color: _statusColor(order.status), size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          order.items.map((i) => i.name).take(2).join(', ') +
                              (order.items.length > 2 ? ' +${order.items.length - 2}' : ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary, fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      Text(
                        '₹${order.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: AppColors.primary, fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormatter.formatRelative(order.placedAt),
                    style: const TextStyle(fontSize: 12, color: AppColors.textHint, fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 6),
                  OrderStatusBadge(status: order.status, isSmall: true),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return AppColors.pending;
      case 'preparing': return AppColors.preparing;
      case 'ready': return AppColors.ready;
      case 'picked_up': return AppColors.pickedUp;
      case 'rejected': return AppColors.rejected;
      default: return AppColors.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.hourglass_empty_rounded;
      case 'preparing': return Icons.restaurant_rounded;
      case 'ready': return Icons.celebration_rounded;
      case 'picked_up': return Icons.check_circle_rounded;
      case 'rejected': return Icons.cancel_rounded;
      default: return Icons.receipt_rounded;
    }
  }
}
