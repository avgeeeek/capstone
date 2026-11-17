import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTextStyles {
  // Display
  static const TextStyle displayLarge = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    height: 1.15,
    fontFamily: 'Inter',
    letterSpacing: -1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.2,
    fontFamily: 'Inter',
    letterSpacing: -0.8,
  );

  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
    letterSpacing: -0.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.55,
    fontFamily: 'Inter',
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.55,
    fontFamily: 'Inter',
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
    fontFamily: 'Inter',
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
    fontFamily: 'Inter',
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 1.0,
    fontFamily: 'Inter',
  );

  // Price
  static const TextStyle priceText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    fontFamily: 'Inter',
  );

  static const TextStyle priceLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: AppColors.primary,
    fontFamily: 'Inter',
  );

  // Caption / Helper
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    fontFamily: 'Inter',
  );

  // Button
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.3,
    fontFamily: 'Inter',
  );

  // Countdown
  static const TextStyle countdownLarge = TextStyle(
    fontSize: 38,
    fontWeight: FontWeight.w900,
    color: AppColors.primary,
    fontFamily: 'Inter',
    letterSpacing: -1.0,
  );
}
