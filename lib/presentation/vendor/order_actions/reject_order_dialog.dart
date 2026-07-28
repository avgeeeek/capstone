import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/order_model.dart';
import '../../../logic/providers/vendor_provider.dart';
import '../../../core/constants/app_colors.dart';

class RejectOrderDialog extends StatefulWidget {
  final OrderModel order;
  const RejectOrderDialog({super.key, required this.order});

  @override
  State<RejectOrderDialog> createState() => _RejectOrderDialogState();
}

class _RejectOrderDialogState extends State<RejectOrderDialog> {
  final _reasonCtrl = TextEditingController();
  bool _isLoading = false;

  final List<String> _presetReasons = [
    'Out of ingredients',
    'Stall closing early',
    'Too many orders',
    'Item not available',
  ];
  String? _selectedReason;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.cancel_rounded, color: AppColors.error),
          SizedBox(width: 8),
          Text('Reject Order', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select a reason (optional):',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Inter'),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _presetReasons.map((r) => GestureDetector(
              onTap: () => setState(() {
                _selectedReason = r;
                _reasonCtrl.text = r;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _selectedReason == r ? AppColors.errorLight : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _selectedReason == r ? AppColors.error : AppColors.border),
                ),
                child: Text(r, style: TextStyle(
                  fontSize: 12, fontFamily: 'Inter',
                  color: _selectedReason == r ? AppColors.error : AppColors.textPrimary,
                )),
              ),
            )).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reasonCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Or type a custom reason...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.error, width: 2),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _reject,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _isLoading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Reject Order', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Future<void> _reject() async {
    setState(() => _isLoading = true);
    final vendor = context.read<VendorProvider>();
    final reason = _reasonCtrl.text.trim().isNotEmpty ? _reasonCtrl.text.trim() : null;
    final success = await vendor.rejectOrder(
      widget.order,
      widget.order.studentId,
      reason: reason,
    );
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Order rejected' : 'Failed to reject order'),
        backgroundColor: success ? AppColors.warning : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }
}
