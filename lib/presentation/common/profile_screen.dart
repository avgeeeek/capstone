import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/widgets/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: TextButton.styleFrom(foregroundColor: AppColors.error),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                final nav = Navigator.of(context);
                await context.read<AuthProvider>().signOut();
                nav.pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: user?.photoUrl != null
                    ? NetworkImage(user!.photoUrl!)
                    : null,
                child: user?.photoUrl == null
                    ? Text(
                        user?.name.isNotEmpty == true
                            ? user!.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontFamily: 'Inter',
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                user?.name ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user?.role.toUpperCase() ?? '',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Info cards
              _InfoCard(icon: Icons.email_outlined, label: 'Email', value: user?.email ?? ''),
              const SizedBox(height: 12),
              _InfoCard(icon: Icons.phone_outlined, label: 'Phone', value: user?.phone ?? ''),
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.badge_outlined,
                label: user?.isVendor == true ? 'Stall Name' : 'College ID',
                value: user?.collegeId ?? '',
              ),
              const SizedBox(height: 40),

              if (user?.isStudent == true)
                CustomButton(
                  text: 'My Order History',
                  variant: ButtonVariant.outline,
                  prefixIcon: Icons.history_rounded,
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.orderHistory),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textHint,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
