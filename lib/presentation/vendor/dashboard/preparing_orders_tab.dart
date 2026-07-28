import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/order_model.dart';
import '../../../logic/providers/vendor_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
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
        subtitle: 'Accepted orders will appear here',
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
