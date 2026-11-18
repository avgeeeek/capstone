import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/repositories/menu_repository.dart';
import '../../../core/constants/app_colors.dart';
import 'toggle_availability_switch.dart';
import 'inventory_widgets.dart';

class MenuItemTileVendor extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MenuItemTileVendor({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: item.isAvailable ? AppColors.surface : AppColors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.isOutOfStock
              ? AppColors.error.withValues(alpha: 0.5)
              : item.isAvailable
                  ? AppColors.border
                  : AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                child: item.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        width: 80, height: 80, fit: BoxFit.cover,
                        placeholder: (_, __) => _placeholder(),
                        errorWidget: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: item.isAvailable ? AppColors.textPrimary : AppColors.textHint,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${item.price.toStringAsFixed(0)} • ${item.category} • ${item.estimatedMinutes ?? 15}m',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Inter'),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          ToggleAvailabilitySwitch(item: item),
                          const SizedBox(width: 8),
                          // Stock badge
                          StockBadge(stockCount: item.stockCount),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Actions
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 20),
                    onPressed: onEdit,
                    padding: const EdgeInsets.all(8),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                    onPressed: onDelete,
                    padding: const EdgeInsets.all(8),
                  ),
                ],
              ),
              const SizedBox(width: 4),
            ],
          ),
          // Quick stock adjust row (only if tracking enabled)
          if (item.hasStockTracking)
            _QuickStockAdjust(item: item),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 80, height: 80,
        color: AppColors.primaryLight,
        child: const Icon(Icons.fastfood_rounded, color: AppColors.primary, size: 32),
      );
}

/// Compact inline row for quickly adding/removing stock without opening edit screen
class _QuickStockAdjust extends StatelessWidget {
  final MenuItemModel item;
  const _QuickStockAdjust({required this.item});

  @override
  Widget build(BuildContext context) {
    final menuRepo = context.read<MenuRepository>();
    final current = item.stockCount ?? 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_rounded, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          const Text(
            'Stock:',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Inter'),
          ),
          const SizedBox(width: 8),
          _adj(context, Icons.remove_rounded, current > 0
              ? () => menuRepo.updateStockCount(item.id, current - 1)
              : null),
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 3),
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: current == 0 ? AppColors.errorLight : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$current',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                fontFamily: 'Inter',
                color: current == 0 ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
          _adj(context, Icons.add_rounded,
              () => menuRepo.updateStockCount(item.id, current + 1)),
          const Spacer(),
          if (current == 0)
            const Text(
              'OUT OF STOCK',
              style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w800,
                color: AppColors.error, fontFamily: 'Inter', letterSpacing: 0.5,
              ),
            )
          else if (current <= 5)
            const Text(
              'LOW STOCK',
              style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w800,
                color: AppColors.warning, fontFamily: 'Inter', letterSpacing: 0.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _adj(BuildContext context, IconData icon, VoidCallback? onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: onTap == null
                ? AppColors.border
                : AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16,
              color: onTap == null ? AppColors.textHint : AppColors.primary),
        ),
      );
}
