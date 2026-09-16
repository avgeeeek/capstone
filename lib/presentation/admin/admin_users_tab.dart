import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/admin_repository.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/empty_state.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  String _searchQuery = '';
  String _selectedFilter = 'all'; // all, student, vendor, admin, pending, rejected

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search by name, email, or role',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),

        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              _filterChip('all', 'All'),
              const SizedBox(width: 8),
              _filterChip('student', 'Students'),
              const SizedBox(width: 8),
              _filterChip('vendor', 'Vendors'),
              const SizedBox(width: 8),
              _filterChip('admin', 'Admins'),
              const SizedBox(width: 8),
              _filterChip('pending', 'Pending'),
              const SizedBox(width: 8),
              _filterChip('rejected', 'Rejected'),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // User list
        Expanded(
          child: StreamBuilder<List<UserModel>>(
            stream: context.read<AdminRepository>().getAllUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const FullScreenLoader();
              }

              var users = snapshot.data ?? [];

              // Filter by chip
              if (_selectedFilter == 'student') {
                users = users.where((u) => u.role == 'student').toList();
              } else if (_selectedFilter == 'vendor') {
                users = users.where((u) => u.role == 'vendor').toList();
              } else if (_selectedFilter == 'admin') {
                users = users.where((u) => u.role == 'admin').toList();
              } else if (_selectedFilter == 'pending') {
                users = users.where((u) => !u.isApproved && !u.isRejected).toList();
              } else if (_selectedFilter == 'rejected') {
                users = users.where((u) => u.isRejected).toList();
              }

              // Search query
              if (_searchQuery.isNotEmpty) {
                final q = _searchQuery.toLowerCase();
                users = users.where((u) =>
                    u.name.toLowerCase().contains(q) ||
                    u.email.toLowerCase().contains(q) ||
                    u.role.toLowerCase().contains(q) ||
                    u.collegeId.toLowerCase().contains(q)).toList();
              }

              if (users.isEmpty) {
                return const EmptyState(
                  title: 'No users found',
                  subtitle: 'Try adjusting your search or filters',
                  icon: Icons.people_outline_rounded,
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 1.5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: user.role == 'vendor'
                              ? AppColors.secondary
                              : user.role == 'admin'
                                  ? Colors.purple
                                  : AppColors.primary,
                          child: Icon(
                            user.role == 'vendor'
                                ? Icons.storefront_rounded
                                : user.role == 'admin'
                                    ? Icons.admin_panel_settings_rounded
                                    : Icons.person_rounded,
                            color: Colors.white,
                          ),
                        ),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                user.name.isEmpty ? 'Unnamed User' : user.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _statusBadge(user),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(user.email, style: const TextStyle(fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(
                              'Role: ${user.role.toUpperCase()}${user.collegeId.isNotEmpty ? '  •  ID: ${user.collegeId}' : ''}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded),
                          onSelected: (val) async {
                            final repo = context.read<AdminRepository>();
                            if (val == 'approve') {
                              await repo.activateUser(user.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('User approved/activated'), backgroundColor: AppColors.success),
                                );
                              }
                            } else if (val == 'reject') {
                              await repo.rejectUser(user.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('User marked as rejected'), backgroundColor: AppColors.error),
                                );
                              }
                            } else if (val == 'deactivate') {
                              await repo.deactivateUser(user.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('User deactivated')),
                                );
                              }
                            } else if (val == 'delete') {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  title: const Text('Delete User Account'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Are you sure you want to permanently delete ${user.name}?'),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.orange.shade200),
                                        ),
                                        child: const Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.warning_amber_rounded,
                                                color: Colors.orange, size: 18),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'To fully free up this email for reuse, also delete the account from Firebase Console → Authentication.',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.orange),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Cancel')),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.error),
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      child: const Text('Delete',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await repo.deleteUser(user.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'User profile deleted. Remember to remove them from Firebase Console → Authentication to free up the email.'),
                                      backgroundColor: AppColors.error,
                                      duration: Duration(seconds: 6),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            if (!user.isApproved)
                              const PopupMenuItem(
                                value: 'approve',
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
                                    SizedBox(width: 8),
                                    Text('Approve / Activate'),
                                  ],
                                ),
                              ),
                            if (!user.isRejected)
                              const PopupMenuItem(
                                value: 'reject',
                                child: Row(
                                  children: [
                                    Icon(Icons.cancel_outlined, color: AppColors.error, size: 18),
                                    SizedBox(width: 8),
                                    Text('Reject Student'),
                                  ],
                                ),
                              ),
                            if (user.isApproved)
                              const PopupMenuItem(
                                value: 'deactivate',
                                child: Row(
                                  children: [
                                    Icon(Icons.pause_circle_outline, color: Colors.orange, size: 18),
                                    SizedBox(width: 8),
                                    Text('Deactivate'),
                                  ],
                                ),
                              ),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                                  SizedBox(width: 8),
                                  Text('Delete Account', style: TextStyle(color: AppColors.error)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedFilter = filterKey);
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
    );
  }

  Widget _statusBadge(UserModel user) {
    Color bg;
    Color text;
    String label;

    if (user.isApproved) {
      bg = AppColors.success.withValues(alpha: 0.12);
      text = AppColors.success;
      label = 'Active';
    } else if (user.isRejected) {
      bg = AppColors.error.withValues(alpha: 0.12);
      text = AppColors.error;
      label = 'Rejected';
    } else {
      bg = Colors.orange.withValues(alpha: 0.15);
      text = Colors.orange.shade800;
      label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
