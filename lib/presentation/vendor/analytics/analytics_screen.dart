import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/order_model.dart';
import '../../../logic/providers/vendor_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/loading_indicator.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vendor = context.watch<VendorProvider>().vendor;
    
    if (vendor == null) {
      return const Scaffold(body: Center(child: Text('Vendor not found')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics & Earnings')),
      body: StreamBuilder<List<OrderModel>>(
        stream: context.read<VendorProvider>().vendorOrdersStream(vendor.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const FullScreenLoader();
          }
          
          final orders = snapshot.data ?? [];
          final today = DateTime.now();
          
          // Filter for completed orders today
          final completedOrders = orders.where((o) => o.status == ApiConstants.statusPickedUp).toList();
          
          final todayOrders = completedOrders.where((o) => 
            o.placedAt.year == today.year && 
            o.placedAt.month == today.month && 
            o.placedAt.day == today.day
          ).toList();
          
          final todayEarnings = todayOrders.fold(0.0, (sum, o) => sum + o.totalAmount);
          final totalEarnings = completedOrders.fold(0.0, (sum, o) => sum + o.totalAmount);
          
          // Cash vs UPI for today
          final todayCash = todayOrders.where((o) => o.isCash).fold(0.0, (sum, o) => sum + o.totalAmount);
          final todayUpi = todayOrders.where((o) => o.isGpay).fold(0.0, (sum, o) => sum + o.totalAmount);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(
                  title: 'Today\'s Earnings',
                  amount: todayEarnings,
                  subtitle: '${todayOrders.length} completed orders',
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSmallCard(
                        title: 'Total Earnings',
                        value: '₹${totalEarnings.toStringAsFixed(0)}',
                        icon: Icons.account_balance_wallet_rounded,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSmallCard(
                        title: 'Total Orders',
                        value: '${completedOrders.length}',
                        icon: Icons.receipt_long_rounded,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Today\'s Payment Breakdown',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _buildPaymentRow('Google Pay (UPI)', todayUpi, AppColors.success),
                      const Divider(height: 24),
                      _buildPaymentRow('Cash at Counter', todayCash, AppColors.warning),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required double amount, required String subtitle, required Color color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Inter')),
          const SizedBox(height: 8),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800, fontFamily: 'Inter', letterSpacing: -1),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Inter')),
        ],
      ),
    );
  }

  Widget _buildSmallCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontFamily: 'Inter')),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, double amount, Color color) {
    return Row(
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 15, fontFamily: 'Inter'))),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
        ),
      ],
    );
  }
}
