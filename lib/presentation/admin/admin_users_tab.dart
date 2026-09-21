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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search users by name, email, or role',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: AppColors.surface,
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<UserModel>>(
            stream: context.read<AdminRepository>().getAllUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const FullScreenLoader();
              }
              
              var users = snapshot.data ?? [];
              
              if (_searchQuery.isNotEmpty) {
                final q = _searchQuery.toLowerCase();
                users = users.where((u) => 
                  u.name.toLowerCase().contains(q) || 
                  u.email.toLowerCase().contains(q) ||
                  u.role.toLowerCase().contains(q)
                ).toList();
              }

              if (users.isEmpty) {
                return const EmptyState(
                  title: 'No users found',
                  subtitle: 'Try a different search query',
                  icon: Icons.people_outline_rounded,
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: user.role == 'vendor' ? AppColors.secondary : AppColors.primary,
                        child: Icon(
                          user.role == 'vendor' ? Icons.storefront_rounded : Icons.person_rounded,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${user.email}\nRole: ${user.role.toUpperCase()}'),
                      isThreeLine: true,
                      trailing: PopupMenuButton(
                        onSelected: (val) async {
                          final repo = context.read<AdminRepository>();
                          if (val == 'deactivate') {
                            await repo.deactivateUser(user.id);
                          } else if (val == 'activate') {
                            await repo.activateUser(user.id);
                          } else if (val == 'delete') {
                            await repo.deleteUser(user.id);
                          }
                        },
                        itemBuilder: (context) => [
                          if (user.isApproved)
                            const PopupMenuItem(value: 'deactivate', child: Text('Deactivate'))
                          else
                            const PopupMenuItem(value: 'activate', child: Text('Activate')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete Account', style: TextStyle(color: Colors.red))),
                        ],
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
}
