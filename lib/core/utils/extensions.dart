import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

extension StringExtension on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String get titleCase {
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}

extension DoubleExtension on double {
  String get toPrice => '₹${toStringAsFixed(2)}';
  String get toPriceInt => '₹${toStringAsFixed(0)}';
}

extension IntExtension on int {
  String get toPrice => '₹$this';

  String get toMinutesString {
    if (this < 60) return '${this}m';
    final h = this ~/ 60;
    final m = this % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}

extension DateTimeExtension on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
}

extension ColorExtension on Color {
  Color get withLowOpacity => withOpacity(0.1);
  Color get withMidOpacity => withOpacity(0.5);
}

extension ContextExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isSmallScreen => screenWidth < 360;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void pop() => Navigator.of(this).pop();
  void pushNamed(String route, {Object? arguments}) =>
      Navigator.of(this).pushNamed(route, arguments: arguments);
  void pushReplacementNamed(String route, {Object? arguments}) =>
      Navigator.of(this).pushReplacementNamed(route, arguments: arguments);
  void pushNamedAndRemoveUntil(String route, {Object? arguments}) =>
      Navigator.of(this).pushNamedAndRemoveUntil(route, (r) => false, arguments: arguments);
}
