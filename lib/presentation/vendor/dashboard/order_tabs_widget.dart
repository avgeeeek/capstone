import 'package:flutter/material.dart';
import '../../../data/models/order_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import 'preparing_orders_tab.dart';
import 'ready_orders_tab.dart';
import 'completed_orders_tab.dart';

class OrderTabsWidget extends StatefulWidget {
  final List<OrderModel> orders;
  final String vendorId;

  const OrderTabsWidget({super.key, required this.orders, required this.vendorId});

  @override
  State<OrderTabsWidget> createState() => _OrderTabsWidgetState();
}

class _OrderTabsWidgetState extends State<OrderTabsWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preparing = widget.orders.where((o) => o.status == ApiConstants.statusPreparing || o.status == ApiConstants.statusPending).toList();
    final ready = widget.orders.where((o) => o.status == ApiConstants.statusReady).toList();
    final completed = widget.orders.where((o) => o.status == ApiConstants.statusPickedUp || o.status == ApiConstants.statusRejected || o.status == ApiConstants.statusCancelled).toList();

    return Column(
      children: [
        Container(
          color: AppColors.surface,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              _tab('Preparing', preparing.length),
              _tab('Ready', ready.length),
              _tab('Done', completed.length),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              PreparingOrdersTab(orders: preparing),
              ReadyOrdersTab(orders: ready),
              CompletedOrdersTab(orders: completed),
            ],
          ),
        ),
      ],
    );
  }

  Tab _tab(String label, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
