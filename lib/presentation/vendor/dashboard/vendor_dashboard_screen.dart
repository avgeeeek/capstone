import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../logic/providers/auth_provider.dart';
import '../../../logic/providers/vendor_provider.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/vendor_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/loading_indicator.dart';
import 'order_tabs_widget.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final vendorProvider = context.watch<VendorProvider>();
    final vendor = vendorProvider.vendor;

    if (vendorProvider.isLoading && vendor == null) {
      return const Scaffold(body: FullScreenLoader(message: 'Loading dashboard...'));
    }

    if (vendor == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No stall found for your account.',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 16)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => vendorProvider.loadVendorByOwnerId(auth.userId),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vendor.stallName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'Inter'),
            ),
            Text(
              vendor.location,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w400, fontFamily: 'Inter'),
            ),
          ],
        ),
        actions: [
          // Stall open/close toggle
          _StallToggle(vendor: vendor),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.studentNotifications),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: vendorProvider.vendorOrdersStream(vendor.id),
        builder: (ctx, snap) {
          final orders = snap.data ?? [];
          if (_navIndex == 0) {
            return OrderTabsWidget(orders: orders, vendorId: vendor.id);
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) {
          setState(() => _navIndex = i);
          switch (i) {
            case 1:
              Navigator.pushNamed(context, AppRoutes.menuManagement);
              setState(() => _navIndex = 0);
              break;
            case 2:
              Navigator.pushNamed(context, AppRoutes.qrScanner);
              setState(() => _navIndex = 0);
              break;
            case 3:
              Navigator.pushNamed(context, AppRoutes.analytics);
              setState(() => _navIndex = 0);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_rounded), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner_rounded), label: 'Scan QR'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Analytics'),
        ],
      ),
    );
  }
}

class _StallToggle extends StatelessWidget {
  final VendorModel vendor;
  const _StallToggle({required this.vendor});

  @override
  Widget build(BuildContext context) {
    final vendorProvider = context.read<VendorProvider>();
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            vendor.isOpen ? 'Open' : 'Closed',
            style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter',
              color: vendor.isOpen ? AppColors.success : AppColors.error,
            ),
          ),
          Switch(
            value: vendor.isOpen,
            activeColor: AppColors.success,
            onChanged: (v) => vendorProvider.toggleStallOpen(v),
          ),
        ],
      ),
    );
  }
}
