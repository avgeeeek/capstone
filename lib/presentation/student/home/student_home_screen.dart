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
  String _searchQuery = '';

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
            child: SearchBarWidget(
              onChanged: (q) => setState(() => _searchQuery = q),
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

        // Filter by search
        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          stalls = stalls.where((v) {
            return v.stallName.toLowerCase().contains(q) ||
                v.cuisine.any((c) => c.toLowerCase().contains(q));
          }).toList();
        }

        if (stalls.isEmpty) {
          return EmptyState(
            title: _searchQuery.isNotEmpty ? 'No stalls found' : 'No stalls open',
            subtitle: _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Check back later when stalls are open',
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
