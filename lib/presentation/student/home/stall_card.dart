import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/vendor_model.dart';
import '../../../core/constants/app_colors.dart';

class StallCard extends StatefulWidget {
  final VendorModel vendor;
  final VoidCallback onTap;

  const StallCard({super.key, required this.vendor, required this.onTap});

  @override
  State<StallCard> createState() => _StallCardState();
}

class _StallCardState extends State<StallCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20)),
                child: widget.vendor.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: widget.vendor.imageUrl!,
                        height: 130,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _placeholder(),
                        errorWidget: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              // Details
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.vendor.stallName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              fontFamily: 'Inter',
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        // Open/Closed pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: widget.vendor.isOpen
                                ? AppColors.success
                                : AppColors.error,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.vendor.isOpen ? '● Open' : '● Closed',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.restaurant_rounded,
                            size: 13, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(
                          widget.vendor.cuisineString,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 13, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.vendor.location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textHint,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        // Rating badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.primary, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 13,
                                  color: AppColors.primary),
                              const SizedBox(width: 3),
                              Text(
                                widget.vendor.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 130,
      width: double.infinity,
      color: AppColors.accent.withValues(alpha: 0.3),
      child: Center(
        child: Text(
          widget.vendor.stallName.isNotEmpty
              ? widget.vendor.stallName[0]
              : '🍽️',
          style: const TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
