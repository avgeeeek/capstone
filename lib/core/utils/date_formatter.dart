import 'package:intl/intl.dart';

class DateFormatter {
  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDate(dateTime);
  }

  static String formatCountdown(Duration remaining) {
    if (remaining.isNegative || remaining.inSeconds <= 0) return '00:00';
    final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (remaining.inHours > 0) {
      final hours = remaining.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  static String formatCountdownReadable(Duration remaining) {
    if (remaining.isNegative || remaining.inSeconds <= 0) return '0m 0s';
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds.remainder(60);
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }

  static String formatPrice(double price) {
    return '₹${price.toStringAsFixed(2)}';
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(amount);
  }
}
