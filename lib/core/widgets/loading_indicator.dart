import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const LoadingIndicator({super.key, this.size = 40, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: color ?? AppColors.primary,
        ),
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const ShimmerCard({
    super.key,
    this.height = 120,
    this.width,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFEDE8C0),   // warm cream base
      highlightColor: const Color(0xFFF8F4D8), // lighter cream highlight
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppColors.borderLight, width: 1.5),
        ),
      ),
    );
  }
}

class StallShimmerList extends StatelessWidget {
  const StallShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 4,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemBuilder: (_, i) => const Padding(
        padding: EdgeInsets.only(bottom: 14),
        child: ShimmerCard(height: 190),
      ),
    );
  }
}

class MenuShimmerGrid extends StatelessWidget {
  const MenuShimmerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: 6,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (_, i) => const ShimmerCard(height: 220),
    );
  }
}

class FullScreenLoader extends StatelessWidget {
  final String? message;

  const FullScreenLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
