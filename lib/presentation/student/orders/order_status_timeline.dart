import 'package:flutter/material.dart';
import '../../../data/models/order_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';

class OrderStatusTimeline extends StatelessWidget {
  final OrderModel order;

  const OrderStatusTimeline({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps(order);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Timeline',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter', color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: List.generate(steps.length, (i) {
              final step = steps[i];
              final isLast = i == steps.length - 1;
              return _TimelineStep(
                step: step,
                isLast: isLast,
              );
            }),
          ),
        ),
      ],
    );
  }

  List<_StepData> _buildSteps(OrderModel order) {
    final steps = <_StepData>[];

    steps.add(_StepData(
      label: 'Order Placed & Payment Done',
      time: DateFormatter.formatTime(order.placedAt),
      isDone: true,
      color: AppColors.success,
    ));

    if (order.isRejected) {
      steps.add(const _StepData(
        label: 'Order Rejected',
        time: '',
        isDone: true,
        color: AppColors.error,
      ));
      return steps;
    }

    final isPreparing = order.isPreparing || order.isReady || order.isPickedUp;
    steps.add(_StepData(
      label: 'Preparing Your Food',
      time: order.estimatedMinutes != null ? 'Est. ${order.estimatedMinutes} min' : '',
      isDone: isPreparing,
      color: AppColors.preparing,
    ));

    final isReady = order.isReady || order.isPickedUp;
    steps.add(_StepData(
      label: 'Ready for Pickup',
      time: order.readyAt != null ? DateFormatter.formatTime(order.readyAt!) : '',
      isDone: isReady,
      color: AppColors.ready,
    ));

    steps.add(_StepData(
      label: 'Picked Up ✓',
      time: order.pickedUpAt != null ? DateFormatter.formatTime(order.pickedUpAt!) : '',
      isDone: order.isPickedUp,
      color: AppColors.pickedUp,
    ));

    return steps;
  }
}

class _StepData {
  final String label;
  final String time;
  final bool isDone;
  final Color color;

  const _StepData({
    required this.label,
    required this.time,
    required this.isDone,
    required this.color,
  });
}

class _TimelineStep extends StatelessWidget {
  final _StepData step;
  final bool isLast;

  const _TimelineStep({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Line + dot
        Column(
          children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: step.isDone ? step.color : AppColors.border,
                shape: BoxShape.circle,
                border: Border.all(
                  color: step.isDone ? step.color : AppColors.border,
                  width: 2,
                ),
              ),
              child: step.isDone
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2, height: 40,
                margin: const EdgeInsets.symmetric(vertical: 2),
                color: step.isDone ? step.color.withValues(alpha: 0.4) : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  step.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: step.isDone ? FontWeight.w600 : FontWeight.w400,
                    color: step.isDone ? AppColors.textPrimary : AppColors.textHint,
                    fontFamily: 'Inter',
                  ),
                ),
                if (step.time.isNotEmpty)
                  Text(
                    step.time,
                    style: const TextStyle(
                      fontSize: 12, color: AppColors.textHint, fontFamily: 'Inter',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
