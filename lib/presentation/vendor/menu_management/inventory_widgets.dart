import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Shared inventory tracking card used in Add / Edit item screens
class InventoryCard extends StatelessWidget {
  final int stockCount;
  final ValueChanged<int> onChangeCount;

  const InventoryCard({
    super.key,
    required this.stockCount,
    required this.onChangeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Stock Quantity',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Live stock count for students; auto marks Out of Stock at 0',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              StockStepper(value: stockCount, onChanged: onChangeCount),
            ],
          ),
          const SizedBox(height: 12),
          // Quick presets for stock count
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [5, 10, 20, 50, 100].map((s) {
              final isSelected = stockCount == s;
              return ChoiceChip(
                label: Text('$s units'),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.background,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontFamily: 'Inter',
                ),
                onSelected: (_) => onChangeCount(s),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          StockStatusChip(stockCount: stockCount),
        ],
      ),
    );
  }
}

/// +/- stepper for stock count
class StockStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const StockStepper({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _btn(Icons.remove_rounded, () {
          if (value > 0) onChanged(value - 1);
        }),
        Container(
          width: 52,
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: value == 0 ? AppColors.errorLight : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontFamily: 'Inter',
              color: value == 0 ? AppColors.error : AppColors.primary,
            ),
          ),
        ),
        _btn(Icons.add_rounded, () => onChanged(value + 1)),
      ],
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
      );
}

/// Color-coded status chip shown below the stock stepper
class StockStatusChip extends StatelessWidget {
  final int stockCount;
  const StockStatusChip({super.key, required this.stockCount});

  @override
  Widget build(BuildContext context) {
    if (stockCount == 0) {
      return _chip(
        Icons.cancel_rounded,
        'Out of Stock — will be hidden from students',
        AppColors.error,
        AppColors.errorLight,
      );
    }
    if (stockCount <= 5) {
      return _chip(
        Icons.warning_amber_rounded,
        'Low stock — only $stockCount left',
        AppColors.warning,
        AppColors.warningLight,
      );
    }
    return _chip(
      Icons.check_circle_rounded,
      '$stockCount items in stock',
      AppColors.success,
      AppColors.successLight,
    );
  }

  Widget _chip(IconData icon, String label, Color color, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      );
}

/// Compact stock badge shown on the vendor menu tile
class StockBadge extends StatelessWidget {
  final int? stockCount;
  const StockBadge({super.key, required this.stockCount});

  @override
  Widget build(BuildContext context) {
    if (stockCount == null) return const SizedBox.shrink(); // unlimited

    final isOut = stockCount! <= 0;
    final isLow = stockCount! > 0 && stockCount! <= 5;

    Color color;
    Color bg;
    String label;
    IconData icon;

    if (isOut) {
      color = AppColors.error;
      bg = AppColors.errorLight;
      label = 'Out of Stock';
      icon = Icons.cancel_rounded;
    } else if (isLow) {
      color = AppColors.warning;
      bg = AppColors.warningLight;
      label = '${stockCount!} left';
      icon = Icons.warning_amber_rounded;
    } else {
      color = AppColors.success;
      bg = AppColors.successLight;
      label = '${stockCount!} in stock';
      icon = Icons.inventory_2_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

/// Preparation time card used in Add / Edit item screens.
class PrepTimeCard extends StatelessWidget {
  final int minutes;
  final ValueChanged<int> onChanged;

  const PrepTimeCard({
    super.key,
    required this.minutes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated Prep Time',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Expected cooking/prep time for students',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              PrepTimeStepper(value: minutes, onChanged: onChanged),
            ],
          ),
          const SizedBox(height: 12),
          // Quick preset choice chips
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [5, 10, 15, 20, 30].map((m) {
              final isSelected = minutes == m;
              return ChoiceChip(
                label: Text('$m mins'),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.background,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontFamily: 'Inter',
                ),
                onSelected: (_) => onChanged(m),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// +/- stepper for preparation minutes
class PrepTimeStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const PrepTimeStepper({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            if (value > 5) {
              onChanged(value - 5);
            } else if (value > 1) {
              onChanged(value - 1);
            }
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.remove_rounded, size: 16, color: AppColors.primary),
          ),
        ),
        Container(
          width: 58,
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$value min',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              fontFamily: 'Inter',
              color: AppColors.primary,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (value < 120) {
              onChanged(value + (value < 5 ? 1 : 5));
            }
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
