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
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _dotController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _textFade;
  @override
  void initState() {
    super.initState();

    // Logo animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _logoController,
          curve: const Interval(0, 0.5, curve: Curves.easeIn)),
    );

    // Text slide-up
    _textController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    _textFade = Tween<double>(begin: 0, end: 1).animate(_textController);

    // Dot bounce loader
    _dotController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();

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
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.adminDashboard, (r) => false);
      } else if (auth.isVendor) {
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
    _logoController.dispose();
    _textController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Decorative blue blobs
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Yellow accent dot
          Positioned(
            top: 80,
            left: 40,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 140,
            right: 50,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Main content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (_, __) => Opacity(
                    opacity: _logoFade.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 40,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // App name + tagline
                AnimatedBuilder(
                  animation: _textController,
                  builder: (_, __) => FadeTransition(
                    opacity: _textFade,
                    child: SlideTransition(
                      position: _textSlide,
                      child: Column(
                        children: [
                          const Text(
                            AppStrings.appName,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Inter',
                              letterSpacing: -1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Skip the queue. Order smart.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 64),
                // Bouncing dot loader
                AnimatedBuilder(
                  animation: _dotController,
                  builder: (_, __) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) {
                      // Stagger offset per dot
                      final stagger = (i * 0.15).clamp(0.0, 1.0);
                      final dotAnim = Tween<double>(begin: 0, end: -12).animate(
                        CurvedAnimation(
                          parent: _dotController,
                          curve: Interval(stagger, (stagger + 0.6).clamp(0.0, 1.0),
                              curve: Curves.easeInOut),
                        ),
                      );
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Transform.translate(
                          offset: Offset(0, dotAnim.value),
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: i == 1
                                  ? AppColors.accent
                                  : AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
