import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../logic/providers/review_provider.dart';
import '../../../../logic/providers/auth_provider.dart';
import '../../../../data/models/order_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_textfield.dart';

class ReviewDialog extends StatefulWidget {
  final OrderModel order;
  final String vendorUserId;

  const ReviewDialog({
    super.key,
    required this.order,
    required this.vendorUserId,
  });

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final auth = context.read<AuthProvider>();
    final reviewProvider = context.read<ReviewProvider>();

    final success = await reviewProvider.submitReview(
      orderId: widget.order.id,
      studentId: auth.userId,
      vendorId: widget.order.vendorId,
      rating: _rating.toDouble(),
      comment: _commentController.text.trim(),
      studentName: auth.userName,
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(reviewProvider.errorMessage ?? 'Failed to submit review')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rate your order from ${widget.order.vendorStallName}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: AppColors.warning,
                  size: 40,
                ),
                onPressed: () => setState(() => _rating = index + 1),
              );
            }),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _commentController,
            label: 'Add a comment (optional)',
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Submit Review',
              isLoading: _isSubmitting,
              onPressed: _submitReview,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
