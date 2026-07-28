import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4B44CC);
  static const Color primaryLight = Color(0xFFEDECFF);

  // Secondary / Accent
  static const Color secondary = Color(0xFFFF6B6B);
  static const Color secondaryLight = Color(0xFFFFE8E8);

  // Success / Status
  static const Color success = Color(0xFF2ECC71);
  static const Color successLight = Color(0xFFD5F5E3);
  static const Color warning = Color(0xFFF39C12);
  static const Color warningLight = Color(0xFFFEF9E7);
  static const Color error = Color(0xFFE74C3C);
  static const Color errorLight = Color(0xFFFDEDEC);
  static const Color info = Color(0xFF3498DB);
  static const Color infoLight = Color(0xFFD6EAF8);

  // Order Status Colors
  static const Color pending = Color(0xFFF39C12);
  static const Color accepted = Color(0xFF3498DB);
  static const Color preparing = Color(0xFF9B59B6);
  static const Color ready = Color(0xFF2ECC71);
  static const Color pickedUp = Color(0xFF27AE60);
  static const Color rejected = Color(0xFFE74C3C);
  static const Color cancelled = Color(0xFF95A5A6);

  // Neutrals
  static const Color background = Color(0xFFF8F9FE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFADB5BD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Borders / Dividers
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF4B44CC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
