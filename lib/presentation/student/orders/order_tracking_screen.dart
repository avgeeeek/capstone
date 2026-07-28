import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/order_status_badge.dart';
import 'order_status_timeline.dart';
import 'countdown_timer.dart';
import 'qr_code_display.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final orderRepo = context.read<OrderRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('Track Order')),
      body: StreamBuilder<OrderModel?>(
        stream: orderRepo.orderStream(orderId),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const FullScreenLoader(message: 'Loading order...');
          }
          final order = snap.data;
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }
          return _buildBody(context, order);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrderModel order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          _buildStatusCard(order),
          const SizedBox(height: 20),

          // Countdown timer (only when preparing)
          if (order.isPreparing && order.estimatedReadyAt != null) ...[
            CountdownTimerWidget(estimatedReadyAt: order.estimatedReadyAt!),
            const SizedBox(height: 20),
          ],

          // QR Code (when ready)
          if (order.isReady) ...[
            QrCodeDisplay(qrData: order.qrCodeData, orderId: orderId),
            const SizedBox(height: 20),
          ],

          // Status timeline
          OrderStatusTimeline(order: order),
          const SizedBox(height: 20),

          // Order items
          _buildOrderItems(order),
          const SizedBox(height: 20),

          // Payment info
          _buildPaymentInfo(order),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatusCard(OrderModel order) {
    final statusColor = _statusColor(order.status);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.15), statusColor.withOpacity(0.05)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(_statusIcon(order.status), color: statusColor, size: 48),
          const SizedBox(height: 12),
          OrderStatusBadge(status: order.status),
          const SizedBox(height: 8),
          Text(
            _statusMessage(order),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14, color: AppColors.textSecondary,
              fontFamily: 'Inter', height: 1.4,
            ),
          ),
          if (order.rejectionReason != null && order.rejectionReason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Reason: ${order.rejectionReason}',
                style: const TextStyle(color: AppColors.error, fontFamily: 'Inter', fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderItems(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Order Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter', color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final item = order.items[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Text('${item.quantity}×', style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w700, fontFamily: 'Inter',
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.name, style: const TextStyle(fontFamily: 'Inter'))),
                    Text('₹${item.total.toStringAsFixed(0)}', style: const TextStyle(
                      fontWeight: FontWeight.w600, fontFamily: 'Inter', color: AppColors.textPrimary,
                    )),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
              Text('₹${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary, fontFamily: 'Inter')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfo(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(order.isGpay ? Icons.payment_rounded : Icons.money_rounded, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.isGpay ? 'Google Pay (UPI)' : 'Cash at Counter',
                style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter'),
              ),
              Text(
                'Payment: ${order.paymentStatus.toUpperCase()}',
                style: TextStyle(
                  fontSize: 12, fontFamily: 'Inter',
                  color: order.paymentStatus == 'paid' ? AppColors.success : AppColors.warning,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case ApiConstants.statusPending: return AppColors.pending;
      case ApiConstants.statusPreparing: return AppColors.preparing;
      case ApiConstants.statusReady: return AppColors.ready;
      case ApiConstants.statusPickedUp: return AppColors.pickedUp;
      case ApiConstants.statusRejected: return AppColors.rejected;
      default: return AppColors.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case ApiConstants.statusPending: return Icons.hourglass_empty_rounded;
      case ApiConstants.statusPreparing: return Icons.restaurant_rounded;
      case ApiConstants.statusReady: return Icons.celebration_rounded;
      case ApiConstants.statusPickedUp: return Icons.check_circle_rounded;
      case ApiConstants.statusRejected: return Icons.cancel_rounded;
      default: return Icons.info_outline_rounded;
    }
  }

  String _statusMessage(OrderModel order) {
    switch (order.status) {
      case ApiConstants.statusPending:
        return 'Your order has been placed. Waiting for the stall to accept.';
      case ApiConstants.statusPreparing:
        return 'The stall is preparing your food. Hang tight!';
      case ApiConstants.statusReady:
        return '🎉 Your food is ready! Show the QR code below to the vendor.';
      case ApiConstants.statusPickedUp:
        return 'Order complete. Enjoy your meal!';
      case ApiConstants.statusRejected:
        return 'Your order was rejected by the stall.';
      default:
        return 'Order status: ${order.status}';
    }
  }
}
