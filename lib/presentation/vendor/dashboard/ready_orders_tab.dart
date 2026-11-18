import 'package:flutter/material.dart';
import '../../../data/models/order_model.dart';
import '../../../core/widgets/empty_state.dart';
import 'order_card_vendor.dart';

class ReadyOrdersTab extends StatelessWidget {
  final List<OrderModel> orders;
  const ReadyOrdersTab({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const EmptyState(
        title: 'No orders ready for pickup',
        subtitle: 'Orders marked ready will appear here',
        icon: Icons.celebration_rounded,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: OrderCardVendor(order: orders[i], showReadyBadge: true),
      ),
    );
  }
}
