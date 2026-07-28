import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/order_model.dart';
import '../../../logic/providers/vendor_provider.dart';
import '../../../core/constants/app_colors.dart';

class AcceptOrderDialog extends StatefulWidget {
  final OrderModel order;
  const AcceptOrderDialog({super.key, required this.order});

  @override
  State<AcceptOrderDialog> createState() => _AcceptOrderDialogState();
}

class _AcceptOrderDialogState extends State<AcceptOrderDialog> {
  int? _selectedMinutes;
  final _customCtrl = TextEditingController();
  bool _showCustomInput = false;
  bool _isLoading = false;

  final List<int> _presetMinutes = [5, 10, 15, 20, 30];

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.timer_outlined, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Ready in how many minutes?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Preset chips
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              ..._presetMinutes.map((m) => _MinuteChip(
                minutes: m,
                isSelected: _selectedMinutes == m && !_showCustomInput,
                onTap: () => setState(() {
                  _selectedMinutes = m;
                  _showCustomInput = false;
                }),
              )),
              _MinuteChip(
                minutes: 0,
                label: 'Custom',
                isSelected: _showCustomInput,
                onTap: () => setState(() {
                  _showCustomInput = true;
                  _selectedMinutes = null;
                }),
              ),
            ],
          ),
          if (_showCustomInput) ...[
            const SizedBox(height: 14),
            TextField(
              controller: _customCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Minutes',
                hintText: 'e.g. 25',
                suffixText: 'min',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              onChanged: (v) {
                final parsed = int.tryParse(v);
                setState(() => _selectedMinutes = parsed);
              },
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: (_selectedMinutes != null && _selectedMinutes! > 0 && !_isLoading)
              ? _accept
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _isLoading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Accept Order', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Future<void> _accept() async {
    if (_selectedMinutes == null || _selectedMinutes! <= 0) return;
    setState(() => _isLoading = true);
    final vendor = context.read<VendorProvider>();
    final success = await vendor.acceptOrder(
      widget.order,
      _selectedMinutes!,
      widget.order.studentId,
    );
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Order accepted! Ready in $_selectedMinutes min' : 'Failed to accept order'),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }
}

class _MinuteChip extends StatelessWidget {
  final int minutes;
  final String? label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MinuteChip({required this.minutes, this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label ?? '${minutes}m',
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600, fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}
