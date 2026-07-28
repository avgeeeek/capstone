import 'package:flutter/material.dart';
import '../../../data/models/order_model.dart';
import '../../../core/widgets/empty_state.dart';
import 'order_card_vendor.dart';

class CompletedOrdersTab extends StatelessWidget {
  final List<OrderModel> orders;
  const CompletedOrdersTab({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const EmptyState(
        title: 'No completed orders',
        subtitle: 'Picked-up and rejected orders appear here',
        icon: Icons.check_circle_outline_rounded,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: OrderCardVendor(order: orders[i]),
      ),
    );
  }
}
