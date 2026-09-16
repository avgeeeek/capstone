import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/auth_provider.dart';
import '../../logic/providers/vendor_provider.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6)),
    );
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    // Wait for the minimum splash duration in parallel with auth loading
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();

    // If auth is still initialising, wait for it to finish before routing
    if (auth.status == AuthStatus.initial || auth.status == AuthStatus.loading) {
      await Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return false;
        final s = context.read<AuthProvider>().status;
        return s == AuthStatus.initial || s == AuthStatus.loading;
      });
    }

    if (!mounted) return;

    if (auth.isAuthenticated) {
      if (auth.isAdmin) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.adminDashboard, (r) => false);
      } else if (auth.isVendor) {
        // Load vendor data then navigate
        final vendorProvider = context.read<VendorProvider>();
        await vendorProvider.loadVendorByOwnerId(auth.userId);
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.vendorDashboard, (r) => false);
        }
      } else {
        if (auth.isApproved) {
          Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.studentHome, (r) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.pendingApproval, (r) => false);
        }
      }
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.login, (r) => false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      AppStrings.appName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Inter',
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Skip the queue. Order smart.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 60),
                    const CircularProgressIndicator(
                      color: Colors.white54,
                      strokeWidth: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
