import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_colors.dart';
import '../constants/api_constants.dart';

class Helpers {
  static final _uuid = const Uuid();

  static String generateId() => _uuid.v4();

  static String generateOrderId() => 'ORD-${_uuid.v4().substring(0, 8).toUpperCase()}';

  static String generateQrData(String orderId) => 'campuseats://order/$orderId';

  static String extractOrderIdFromQr(String qrData) {
    if (qrData.startsWith('campuseats://order/')) {
      return qrData.replaceFirst('campuseats://order/', '');
    }
    return qrData;
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case ApiConstants.statusPending:
        return AppColors.pending;
      case ApiConstants.statusAccepted:
        return AppColors.accepted;
      case ApiConstants.statusPreparing:
        return AppColors.preparing;
      case ApiConstants.statusReady:
        return AppColors.ready;
      case ApiConstants.statusPickedUp:
        return AppColors.pickedUp;
      case ApiConstants.statusRejected:
        return AppColors.rejected;
      case ApiConstants.statusCancelled:
        return AppColors.cancelled;
      default:
        return AppColors.textSecondary;
    }
  }

  static String getStatusLabel(String status) {
    switch (status) {
      case ApiConstants.statusPending:
        return 'Pending';
      case ApiConstants.statusAccepted:
        return 'Accepted';
      case ApiConstants.statusPreparing:
        return 'Preparing';
      case ApiConstants.statusReady:
        return 'Ready for Pickup!';
      case ApiConstants.statusPickedUp:
        return 'Picked Up';
      case ApiConstants.statusRejected:
        return 'Rejected';
      case ApiConstants.statusCancelled:
        return 'Cancelled';
      default:
        return status;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status) {
      case ApiConstants.statusPending:
        return Icons.hourglass_empty_rounded;
      case ApiConstants.statusAccepted:
        return Icons.check_circle_outline_rounded;
      case ApiConstants.statusPreparing:
        return Icons.restaurant_rounded;
      case ApiConstants.statusReady:
        return Icons.done_all_rounded;
      case ApiConstants.statusPickedUp:
        return Icons.shopping_bag_rounded;
      case ApiConstants.statusRejected:
        return Icons.cancel_rounded;
      case ApiConstants.statusCancelled:
        return Icons.close_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  static String buildUpiUri({
    required String upiId,
    required String vendorName,
    required String transactionNote,
    required double amount,
    required String transactionId,
  }) {
    final encodedNote = Uri.encodeComponent(transactionNote);
    final encodedName = Uri.encodeComponent(vendorName);
    return 'upi://pay?pa=$upiId&pn=$encodedName&tn=$encodedNote&am=${amount.toStringAsFixed(2)}&cu=INR&tr=$transactionId&mc=5812';
  }

  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: isDangerous
                ? TextButton.styleFrom(foregroundColor: AppColors.error)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
