import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/repositories/menu_repository.dart';
import '../../../core/constants/app_colors.dart';
import 'toggle_availability_switch.dart';

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
        color: item.isAvailable ? AppColors.surface : AppColors.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.isAvailable ? AppColors.border : AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Row(
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
                    '₹${item.price.toStringAsFixed(0)} • ${item.category}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 6),
                  ToggleAvailabilitySwitch(item: item),
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
    );
  }

  Widget _placeholder() => Container(
    width: 80, height: 80,
    color: AppColors.primaryLight,
    child: const Icon(Icons.fastfood_rounded, color: AppColors.primary, size: 32),
  );
}
