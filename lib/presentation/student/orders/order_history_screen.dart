import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../logic/providers/auth_provider.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import 'order_history_tile.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final orderRepo = context.read<OrderRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: StreamBuilder<List<OrderModel>>(
        stream: orderRepo.studentOrdersStream(auth.userId),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const FullScreenLoader(message: 'Loading orders...');
          }
          final orders = snap.data ?? [];
          if (orders.isEmpty) {
            return EmptyState(
              title: 'No orders yet',
              subtitle: 'Place your first order from a stall!',
              icon: Icons.receipt_long_rounded,
              action: ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.studentHome, (r) => false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Browse Stalls'),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OrderHistoryTile(
                order: orders[i],
                onTap: () => Navigator.pushNamed(context, AppRoutes.orderTracking, arguments: orders[i].id),
              ),
            ),
          );
        },
      ),
    );
  }
}
