import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/models/order_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/order_status_badge.dart';

class OrderCardVendor extends StatefulWidget {
  final OrderModel order;
  final List<Widget>? actions;
  final bool showCountdown;
  final bool showReadyBadge;

  const OrderCardVendor({
    super.key,
    required this.order,
    this.actions,
    this.showCountdown = false,
    this.showReadyBadge = false,
  });

  @override
  State<OrderCardVendor> createState() => _OrderCardVendorState();
}

class _OrderCardVendorState extends State<OrderCardVendor> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.showCountdown && widget.order.estimatedReadyAt != null) {
      _remaining = widget.order.estimatedReadyAt!.difference(DateTime.now());
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          _remaining = widget.order.estimatedReadyAt!.difference(DateTime.now());
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        border: widget.showReadyBadge
            ? Border.all(color: AppColors.success.withValues(alpha: 0.4), width: 1.5)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.id.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary, fontFamily: 'Inter',
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                OrderStatusBadge(status: order.status, isSmall: true),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              DateFormatter.formatDateTime(order.placedAt),
              style: const TextStyle(fontSize: 11, color: AppColors.textHint, fontFamily: 'Inter'),
            ),
            const Divider(height: 16),

            // Items
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Text(
                    '${item.quantity}×',
                    style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w700,
                      fontFamily: 'Inter', fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(item.name, style: const TextStyle(fontSize: 13, fontFamily: 'Inter', color: AppColors.textPrimary)),
                  ),
                  Text(
                    '₹${item.total.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
                  ),
                ],
              ),
            )),

            const Divider(height: 16),

            // Total + payment
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800,
                        color: AppColors.primary, fontFamily: 'Inter',
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: order.isCash ? AppColors.warningLight : AppColors.successLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.isCash ? '💵 Cash Payment' : '💳 GPay ${order.paymentStatus == 'paid' ? '✓' : '?'}',
                        style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Inter',
                          color: order.isCash ? AppColors.warning : AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),

                // Countdown
                if (widget.showCountdown && widget.order.estimatedReadyAt != null)
                  _buildCountdown(),

                // Ready badge
                if (widget.showReadyBadge)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.celebration_rounded, color: AppColors.success, size: 20),
                        Text('Awaiting\nPickup', textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                      ],
                    ),
                  ),
              ],
            ),

            // Actions
            if (widget.actions != null && widget.actions!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(children: widget.actions!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCountdown() {
    final isExpired = _remaining.isNegative || _remaining.inSeconds <= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.timer_outlined, color: Colors.white, size: 16),
          Text(
            isExpired ? 'Done!' : DateFormatter.formatCountdownReadable(_remaining),
            style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w800,
              fontFamily: 'Inter', fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
