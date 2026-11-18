import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../logic/providers/vendor_provider.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/repositories/menu_repository.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import 'menu_item_tile_vendor.dart';

class MenuManagementScreen extends StatelessWidget {
  const MenuManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vendor = context.read<VendorProvider>().vendor;
    final menuRepo = context.read<MenuRepository>();

    if (vendor == null) {
      return const Scaffold(body: Center(child: Text('No vendor found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary, size: 28),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.addMenuItem),
          ),
        ],
      ),
      body: StreamBuilder<List<MenuItemModel>>(
        stream: menuRepo.getMenuItemsForVendor(vendor.id),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const FullScreenLoader();
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return EmptyState(
              title: 'No menu items',
              subtitle: 'Add your first item to attract students!',
              icon: Icons.restaurant_menu_rounded,
              action: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.addMenuItem),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            );
          }

          // Group by category
          final byCategory = <String, List<MenuItemModel>>{};
          for (final item in items) {
            byCategory.putIfAbsent(item.category, () => []).add(item);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: byCategory.length,
            itemBuilder: (_, i) {
              final category = byCategory.keys.elementAt(i);
              final categoryItems = byCategory[category]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 12),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary, fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  ...categoryItems.map((item) => MenuItemTileVendor(
                    item: item,
                    onEdit: () => Navigator.pushNamed(context, AppRoutes.editMenuItem, arguments: item),
                    onDelete: () => _confirmDelete(context, item, menuRepo),
                  )),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addMenuItem),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Item', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, MenuItemModel item, MenuRepository repo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item?'),
        content: Text('Delete "${item.name}" from your menu?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await repo.deleteMenuItem(item.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.name} deleted'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }
}
