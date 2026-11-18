import 'package:flutter/material.dart';
import '../../../data/models/order_model.dart';
import '../../../core/widgets/empty_state.dart';
import '../order_actions/mark_ready_button.dart';
import 'order_card_vendor.dart';

class PreparingOrdersTab extends StatelessWidget {
  final List<OrderModel> orders;
  const PreparingOrdersTab({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const EmptyState(
        title: 'No orders being prepared',
        subtitle: 'New orders will appear here after payment',
        icon: Icons.restaurant_rounded,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: OrderCardVendor(
          order: orders[i],
          showCountdown: true,
          actions: [MarkReadyButton(order: orders[i])],
        ),
      ),
    );
  }
}
