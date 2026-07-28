import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import '../../core/utils/helpers.dart';

class PaymentService {
  /// Launches Google Pay via UPI Deep Link
  /// Returns true if the URL was launched successfully
  Future<bool> launchGooglePay({
    required String vendorUpiId,
    required String vendorName,
    required double amount,
    required String orderId,
    required String transactionNote,
  }) async {
    final upiUri = Helpers.buildUpiUri(
      upiId: vendorUpiId,
      vendorName: vendorName,
      transactionNote: transactionNote,
      amount: amount,
      transactionId: orderId,
    );

    final uri = Uri.parse(upiUri);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      return launched;
    } catch (e) {
      return false;
    }
  }

  /// Shows a dialog prompting user to confirm payment was completed
  Future<bool> showPaymentConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.payment_rounded, color: Color(0xFF6C63FF)),
            SizedBox(width: 8),
            Text(
              'Payment Confirmation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
            ),
          ],
        ),
        content: const Text(
          'After completing your Google Pay payment, tap "Done" to confirm your order.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Done — Payment Complete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Checks if a UPI app is available
  Future<bool> canLaunchUpi() async {
    final testUri = Uri.parse('upi://pay');
    return await canLaunchUrl(testUri);
  }
}
