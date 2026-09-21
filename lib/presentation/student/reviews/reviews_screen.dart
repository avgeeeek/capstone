import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../logic/providers/review_provider.dart';
import '../../../data/models/review_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state.dart';

class ReviewsScreen extends StatelessWidget {
  final String vendorId;
  final String vendorName;
  final double averageRating;

  const ReviewsScreen({
    super.key,
    required this.vendorId,
    required this.vendorName,
    required this.averageRating,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reviews'),
        backgroundColor: AppColors.surface,
      ),
      body: Column(
        children: [
          _buildRatingHeader(),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<ReviewModel>>(
              stream: context.read<ReviewProvider>().getVendorReviewsStream(vendorId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const FullScreenLoader();
                }

                final reviews = snapshot.data ?? [];

                if (reviews.isEmpty) {
                  return const EmptyState(
                    title: 'No reviews yet',
                    subtitle: 'Be the first to review this stall after placing an order!',
                    icon: Icons.star_outline_rounded,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: reviews.length,
                  separatorBuilder: (context, index) => const Divider(height: 32),
                  itemBuilder: (context, index) => _ReviewCard(review: reviews[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingHeader() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            averageRating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < averageRating.floor()
                        ? Icons.star_rounded
                        : (index < averageRating
                            ? Icons.star_half_rounded
                            : Icons.star_outline_rounded),
                    color: AppColors.warning,
                    size: 24,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                vendorName,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              review.studentName ?? 'Student',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
            Text(
              _formatDate(review.createdAt),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
              color: AppColors.warning,
              size: 16,
            );
          }),
        ),
        if (review.comment != null && review.comment!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            review.comment!,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Inter',
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
