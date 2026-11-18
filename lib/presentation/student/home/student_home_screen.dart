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

class _StudentHomeScreenState extends State<StudentHomeScreen>
    with SingleTickerProviderStateMixin {
  int _bottomNavIndex = 0;
  late AnimationController _bannerController;
  late Animation<double> _bannerFade;
  late Animation<Offset> _bannerSlide;

  @override
  void initState() {
    super.initState();
    _bannerController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _bannerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bannerController, curve: Curves.easeOut),
    );
    _bannerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _bannerController, curve: Curves.easeOutCubic),
    );
    _bannerController.forward();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final firstName = auth.userName.isNotEmpty
        ? auth.userName.split(' ').first
        : 'Student';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Sticky header (AppBar-like) ──
          FadeTransition(
            opacity: _bannerFade,
            child: SlideTransition(
              position: _bannerSlide,
              child: _buildHeader(context, firstName, cart),
            ),
          ),
          // ── Stall list ──
          Expanded(child: _buildStallList(context)),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader(
      BuildContext context, String firstName, CartProvider cart) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: greeting + cart icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VIT-AP UNIVERSITY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary
                                .withValues(alpha: 0.45),
                            fontFamily: 'Inter',
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${Helpers.getGreeting()}, $firstName?',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Inter',
                            color: AppColors.textPrimary,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Cart button
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.cart),
                    child: Stack(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.primary, width: 2),
                          ),
                          child: const Icon(Icons.shopping_cart_outlined,
                              color: AppColors.textOnAccent, size: 22),
                        ),
                        if (cart.itemCount > 0)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${cart.itemCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.profile),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_outline_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ── Promo Banner ──
              _PromoTicker(),

              const SizedBox(height: 16),

              // ── Search bar ──
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.search),
                child: AbsorbPointer(
                  child: SearchBarWidget(onChanged: (_) {}),
                ),
              ),
              const SizedBox(height: 16),

              // ── Section label ──
              const Text(
                'STALLS NEAR YOU',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
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
        final stalls = snap.data ?? [];

        if (stalls.isEmpty) {
          return const EmptyState(
            title: 'No stalls open',
            subtitle: 'Check back later when stalls are open',
            icon: Icons.storefront_rounded,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          itemCount: stalls.length,
          itemBuilder: (_, i) => _AnimatedStallCard(
            index: i,
            child: Padding(
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
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: _bottomNavIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700, fontFamily: 'Inter', fontSize: 11),
          unselectedLabelStyle: const TextStyle(
              fontFamily: 'Inter', fontSize: 11),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: (i) {
            setState(() => _bottomNavIndex = i);
            switch (i) {
              case 1:
                Navigator.pushNamed(context, AppRoutes.orderHistory);
                break;
              case 2:
                Navigator.pushNamed(
                    context, AppRoutes.studentNotifications);
                break;
              case 3:
                Navigator.pushNamed(context, AppRoutes.profile);
                break;
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: _navIcon(Icons.home_rounded, 0),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _navIcon(Icons.receipt_long_rounded, 1),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: _navIcon(Icons.notifications_outlined, 2),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: _navIcon(Icons.person_outline_rounded, 3),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, int index) {
    final selected = _bottomNavIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? AppColors.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon,
          color: selected ? AppColors.primary : AppColors.textHint,
          size: 22),
    );
  }
}

// ── Animated stall card wrapper ──────────────────────────────────────────────
class _AnimatedStallCard extends StatefulWidget {
  final Widget child;
  final int index;
  const _AnimatedStallCard({required this.child, required this.index});

  @override
  State<_AnimatedStallCard> createState() => _AnimatedStallCardState();
}

class _AnimatedStallCardState extends State<_AnimatedStallCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: Duration(milliseconds: 400 + widget.index * 80),
      vsync: this,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ── Promo ticker banner ───────────────────────────────────────────────────────
class _PromoTicker extends StatefulWidget {
  @override
  State<_PromoTicker> createState() => _PromoTickerState();
}

class _PromoTickerState extends State<_PromoTicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _shimmer = Tween<double>(begin: -2, end: 2).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryDark, width: 2),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Free Fries\non 2 combos',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Inter',
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Today only at campus stalls',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Animated yellow badge
          AnimatedBuilder(
            animation: _shimmer,
            builder: (_, __) => Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.6),
                    blurRadius: 12 + _shimmer.value.abs() * 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(Icons.local_offer_rounded,
                  color: AppColors.primary, size: 26),
            ),
          ),
        ],
      ),
    );
  }
}
