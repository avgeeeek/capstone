import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/order_model.dart';
import '../../../logic/providers/vendor_provider.dart';
import '../../../core/constants/app_colors.dart';

class MarkReadyButton extends StatefulWidget {
  final OrderModel order;
  const MarkReadyButton({super.key, required this.order});

  @override
  State<MarkReadyButton> createState() => _MarkReadyButtonState();
}

class _MarkReadyButtonState extends State<MarkReadyButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _markReady,
      icon: _isLoading
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Icon(Icons.done_all_rounded, size: 16),
      label: const Text('Mark Ready'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 14),
      ),
    );
  }

  Future<void> _markReady() async {
    setState(() => _isLoading = true);
    final vendor = context.read<VendorProvider>();
    final success = await vendor.markOrderReady(widget.order, widget.order.studentId);
    if (mounted) {
      setState(() => _isLoading = false);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to mark order as ready'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }
}
