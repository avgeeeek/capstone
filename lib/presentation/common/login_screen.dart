import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/auth_provider.dart';
import '../../logic/providers/vendor_provider.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';

import '../../core/widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  late AnimationController _animController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(_animController);
    _animController.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _navigateToRoleScreen(AuthProvider auth) async {
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
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    if (!mounted) return;
    if (success) {
      await _navigateToRoleScreen(auth);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Login failed'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Decorative top-right circle
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Yellow dot accent
          Positioned(
            top: 100,
            right: 60,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Decorative bottom-left circle
          Positioned(
            bottom: -70,
            left: -70,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        // Logo
                        Center(
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.35),
                                  blurRadius: 28,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(26),
                              child: Image.asset(
                                'assets/images/app_logo.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        // Heading
                        const Text(
                          'Welcome back!',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Inter',
                            color: AppColors.textPrimary,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Sign in to continue ordering',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 36),
                        CustomTextField(
                          label: 'Email',
                          hint: 'your@college.edu',
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                          prefixIcon: const Icon(Icons.email_outlined,
                              color: AppColors.textHint),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Password',
                          hint: '••••••••',
                          controller: _passwordCtrl,
                          obscureText: true,
                          validator: Validators.validatePassword,
                          prefixIcon: const Icon(Icons.lock_outline_rounded,
                              color: AppColors.textHint),
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.pushNamed(
                                context, AppRoutes.forgotPassword),
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Sign-in button — yellow accent style
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: auth.isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: auth.isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white),
                                  )
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Inter',
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Divider
                        const Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: AppColors.borderLight,
                                    thickness: 1.5)),
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'or continue with',
                                style: TextStyle(
                                  color: AppColors.textHint,
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                                child: Divider(
                                    color: AppColors.borderLight,
                                    thickness: 1.5)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Google button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton(
                            onPressed: auth.isLoading
                                ? null
                                : () async {
                                    final success =
                                        await auth.loginWithGoogle();
                                    if (!context.mounted) return;
                                    if (success) {
                                      await _navigateToRoleScreen(auth);
                                    } else if (auth.errorMessage != null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  auth.errorMessage!)));
                                    }
                                  },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: const BorderSide(
                                  color: AppColors.border, width: 2),
                              backgroundColor: AppColors.surface,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset('assets/icons/google.svg',
                                    height: 22),
                                const SizedBox(width: 12),
                                const Text(
                                  'Sign in with Google',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        // Sign up link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontFamily: 'Inter',
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.register),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: AppColors.textOnAccent,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
