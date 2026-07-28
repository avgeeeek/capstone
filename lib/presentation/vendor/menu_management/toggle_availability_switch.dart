import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/repositories/menu_repository.dart';
import '../../../core/constants/app_colors.dart';

class ToggleAvailabilitySwitch extends StatelessWidget {
  final MenuItemModel item;

  const ToggleAvailabilitySwitch({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.isAvailable ? 'In Stock' : 'Out of Stock',
          style: TextStyle(
            fontSize: 11, fontFamily: 'Inter', fontWeight: FontWeight.w500,
            color: item.isAvailable ? AppColors.success : AppColors.error,
          ),
        ),
        const SizedBox(width: 6),
        Transform.scale(
          scale: 0.75,
          child: Switch(
            value: item.isAvailable,
            activeColor: AppColors.success,
            onChanged: (v) async {
              final repo = context.read<MenuRepository>();
              await repo.toggleAvailability(item.id, v);
            },
          ),
        ),
      ],
    );
  }
}
