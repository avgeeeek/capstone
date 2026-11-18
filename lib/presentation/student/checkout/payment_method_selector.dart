import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';

class PaymentMethodSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 17, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary, fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 12),
        _PaymentOption(
          id: ApiConstants.paymentGpay,
          selected: selected,
          emoji: '💳',
          title: 'Google Pay (UPI)',
          subtitle: 'Pay instantly via UPI deep link',
          onTap: onSelected,
        ),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String id;
  final String selected;
  final String emoji;
  final String title;
  final String subtitle;
  final ValueChanged<String> onTap;

  const _PaymentOption({
    required this.id,
    required this.selected,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == id;
    return GestureDetector(
      onTap: () => onTap(id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: 2),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
