import 'package:flutter/material.dart';

class AppColors {
  // ── Primary Brand (Deep Blue from the design) ──
  static const Color primary = Color(0xFF1A1AE6);
  static const Color primaryDark = Color(0xFF1010B8);
  static const Color primaryLight = Color(0xFFE8E8FF);

  // ── Accent (Bright Yellow from the design) ──
  static const Color accent = Color(0xFFFFE000);
  static const Color accentDark = Color(0xFFD4BA00);
  static const Color accentLight = Color(0xFFFFF8CC);

  // ── Secondary / Coral (pill badge colour) ──
  static const Color secondary = Color(0xFFFF6B35);
  static const Color secondaryLight = Color(0xFFFFEDE6);

  // ── Success / Status ──
  static const Color success = Color(0xFF2EAD56);
  static const Color successLight = Color(0xFFCCF0D8);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFE63030);
  static const Color errorLight = Color(0xFFFFE0E0);
  static const Color info = Color(0xFF1A1AE6);
  static const Color infoLight = Color(0xFFE8E8FF);

  // ── Order Status Colors ──
  static const Color pending = Color(0xFFF59E0B);
  static const Color accepted = Color(0xFF1A1AE6);
  static const Color preparing = Color(0xFF7C3AED);
  static const Color ready = Color(0xFF2EAD56);
  static const Color pickedUp = Color(0xFF16803C);
  static const Color rejected = Color(0xFFE63030);
  static const Color cancelled = Color(0xFF9CA3AF);

  // ── Neutrals (Cream palette from the design) ──
  static const Color background = Color(0xFFF5F0C8);   // warm cream
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFFAF6E4);   // slightly darker cream

  // ── Text ──
  static const Color textPrimary = Color(0xFF0F0F0F);
  static const Color textSecondary = Color(0xFF3D3D3D);
  static const Color textHint = Color(0xFF8A8A8A);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFF0F0F0F);  // black on yellow

  // ── Borders / Dividers ──
  static const Color border = Color(0xFF1A1AE6);        // blue border as in design
  static const Color borderLight = Color(0xFFDDD8B0);   // subtle cream border
  static const Color divider = Color(0xFFF0ECC8);

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A1AE6), Color(0xFF0D0DA0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1A1AE6), Color(0xFF0808C8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFFE000), Color(0xFFFFBB00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient creamGradient = LinearGradient(
    colors: [Color(0xFFF5F0C8), Color(0xFFF0EAB8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
