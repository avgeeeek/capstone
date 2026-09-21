import 'package:flutter/material.dart';
import '../../../data/models/order_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../order_actions/accept_order_dialog.dart';
import '../order_actions/reject_order_dialog.dart';
import 'order_card_vendor.dart';

class IncomingOrdersTab extends StatelessWidget {
  final List<OrderModel> orders;
  const IncomingOrdersTab({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const EmptyState(
        title: 'No incoming orders',
        subtitle: 'New orders will appear here in real-time',
        icon: Icons.inbox_rounded,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: OrderCardVendor(
          order: orders[i],
          actions: [
            ElevatedButton.icon(
              onPressed: () => _showAcceptDialog(context, orders[i]),
              icon: const Icon(Icons.check_rounded, size: 16),
              label: const Text('Accept'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => _showRejectDialog(context, orders[i]),
              icon: const Icon(Icons.close_rounded, size: 16),
              label: const Text('Reject'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAcceptDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (_) => AcceptOrderDialog(order: order),
    );
  }

  void _showRejectDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (_) => RejectOrderDialog(order: order),
    );
  }
}
