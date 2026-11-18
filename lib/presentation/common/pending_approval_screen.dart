import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/widgets/custom_button.dart';

class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  bool _isChecking = false;

  Future<void> _checkStatus() async {
    setState(() => _isChecking = true);
    final auth = context.read<AuthProvider>();
    await auth.init();
    if (!mounted) return;
    setState(() => _isChecking = false);

    if (auth.isApproved) {
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.studentHome, (r) => false);
    } else if (auth.isRejected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your account remains rejected. Please contact admin.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account is still pending approval.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isRejected = auth.isRejected;

    return Scaffold(
      appBar: AppBar(
        title: Text(isRejected ? 'Account Rejected' : 'Account Pending'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Log Out',
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.login, (r) => false);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: isRejected
                        ? AppColors.error.withValues(alpha: 0.1)
                        : AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isRejected
                        ? Icons.cancel_outlined
                        : Icons.hourglass_empty_rounded,
                    size: 56,
                    color: isRejected ? AppColors.error : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  isRejected ? 'Account Rejected' : 'Approval Pending',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Inter',
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle description
                Text(
                  isRejected
                      ? 'You have been rejected. Please contact admin for more details.'
                      : 'Because you registered with an external email, your account requires manual approval by an administrator before you can order food.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: isRejected
                        ? AppColors.error
                        : AppColors.textSecondary,
                    fontFamily: 'Inter',
                    height: 1.5,
                    fontWeight:
                        isRejected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 32),

                // Action buttons
                CustomButton(
                  text: _isChecking ? 'Checking...' : 'Check Status Again',
                  isLoading: _isChecking,
                  onPressed: _isChecking ? null : _checkStatus,
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () async {
                    await context.read<AuthProvider>().signOut();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, AppRoutes.login, (r) => false);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: AppColors.divider),
                  ),
                  child: const Text(
                    'Log In with Another Account',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
