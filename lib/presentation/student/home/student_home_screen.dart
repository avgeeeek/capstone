import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../logic/providers/auth_provider.dart';
import '../../../logic/providers/cart_provider.dart';
import '../../../data/models/vendor_model.dart';
import '../../../data/repositories/vendor_repository.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state.dart';
import 'stall_card.dart';
import 'search_bar_widget.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _bottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${Helpers.getGreeting()},',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              auth.userName.isNotEmpty ? auth.userName.split(' ').first : 'Student',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                color: AppColors.textPrimary,
                onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
              ),
              if (cart.itemCount > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.search),
              child: AbsorbPointer(
                child: SearchBarWidget(
                  onChanged: (q) {},
                ),
              ),
            ),
          ),
          // Stall List
          Expanded(
            child: _buildStallList(context),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (i) {
          setState(() => _bottomNavIndex = i);
          switch (i) {
            case 1:
              Navigator.pushNamed(context, AppRoutes.orderHistory);
              break;
            case 2:
              Navigator.pushNamed(context, AppRoutes.studentNotifications);
              break;
            case 3:
              Navigator.pushNamed(context, AppRoutes.profile);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildStallList(BuildContext context) {
    final vendorRepo = context.read<VendorRepository>();
    return StreamBuilder<List<VendorModel>>(
      stream: vendorRepo.getOpenVendors(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const StallShimmerList();
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        var stalls = snap.data ?? [];

        // We moved search to a dedicated screen, so we don't filter locally anymore
        // unless you want to keep the local filter for offline use, but
        // typically a dedicated screen is better for full text search.

        if (stalls.isEmpty) {
          return const EmptyState(
            title: 'No stalls open',
            subtitle: 'Check back later when stalls are open',
            icon: Icons.storefront_rounded,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          itemCount: stalls.length,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: StallCard(
              vendor: stalls[i],
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.stallMenu,
                arguments: stalls[i],
              ),
            ),
          ),
        );
      },
    );
  }
}
