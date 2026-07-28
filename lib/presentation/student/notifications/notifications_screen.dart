import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../logic/providers/auth_provider.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final notifRepo = context.read<NotificationRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => notifRepo.markAllAsRead(auth.userId),
            child: const Text('Mark all read', style: TextStyle(color: AppColors.primary, fontFamily: 'Inter', fontSize: 13)),
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: notifRepo.notificationsStream(auth.userId),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const FullScreenLoader();
          }
          final notifs = snap.data ?? [];
          if (notifs.isEmpty) {
            return const EmptyState(
              title: 'No notifications',
              subtitle: 'You\'ll see order updates here',
              icon: Icons.notifications_outlined,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifs.length,
            itemBuilder: (_, i) => _NotifTile(
              notif: notifs[i],
              onTap: () => notifRepo.markAsRead(notifs[i].id),
            ),
          );
        },
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final NotificationModel notif;
  final VoidCallback onTap;

  const _NotifTile({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead ? AppColors.surface : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notif.isRead ? AppColors.border : AppColors.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _typeColor(notif.type).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(_typeEmoji(notif.type), style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.title,
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary, fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(notif.body, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Inter', height: 1.4)),
                  const SizedBox(height: 6),
                  Text(DateFormatter.formatRelative(notif.createdAt),
                      style: const TextStyle(fontSize: 11, color: AppColors.textHint, fontFamily: 'Inter')),
                ],
              ),
            ),
            if (!notif.isRead)
              Container(
                width: 8, height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }

  String _typeEmoji(String type) {
    switch (type) {
      case 'new_order': return '🍽️';
      case 'order_accepted': return '✅';
      case 'order_ready': return '🎉';
      case 'order_rejected': return '❌';
      default: return '🔔';
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'new_order': return AppColors.info;
      case 'order_accepted': return AppColors.success;
      case 'order_ready': return AppColors.success;
      case 'order_rejected': return AppColors.error;
      default: return AppColors.primary;
    }
  }
}
