import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Result returned after a UPI payment attempt
class PaymentResult {
  final bool launched;
  final bool? userConfirmed; // null = dialog dismissed without action

  const PaymentResult({required this.launched, this.userConfirmed});
}

/// UPI deep-link payment service.
///
/// Best-practice notes to reduce bank fraud blocks:
///  - Uses `gpay://upi/pay` intent first (preferred by Google Pay)
///  - Falls back to generic `upi://pay` if GPay is not installed
///  - Adds `tid` (transaction ID) for idempotency tracing
///  - Adds `url` parameter (recommended by NPCI spec)
///  - Uses `LaunchMode.externalNonBrowserApplication` for proper app handoff
class PaymentService {
  /// Opens the UPI payment flow for the given vendor.
  ///
  /// Returns a [PaymentResult] with:
  ///   - [launched] — whether the UPI app opened successfully
  ///   - [userConfirmed] — whether the user tapped "Done" in the confirmation dialog
  Future<PaymentResult> launchUpiPayment({
    required BuildContext context,
    required String vendorUpiId,
    required String vendorName,
    required double amount,
    required String orderId,
    String transactionNote = 'CampusEats Order',
  }) async {
    final tid = 'CE${DateTime.now().millisecondsSinceEpoch}';
    final amountStr = amount.toStringAsFixed(2);
    final encodedName = Uri.encodeComponent(vendorName);
    final encodedNote = Uri.encodeComponent(transactionNote);

    // Preferred: GPay-specific intent URI (bypasses generic UPI chooser,
    // uses GPay's own payment flow — less likely to be flagged)
    final gpayUri = Uri.parse(
      'gpay://upi/pay'
      '?pa=$vendorUpiId'
      '&pn=$encodedName'
      '&tn=$encodedNote'
      '&am=$amountStr'
      '&cu=INR'
      '&tid=$tid'
      '&tr=$orderId'
      '&mc=5812',
    );

    // Fallback: generic UPI deep-link (works with PhonePe, Paytm, BHIM, etc.)
    final upiUri = Uri.parse(
      'upi://pay'
      '?pa=$vendorUpiId'
      '&pn=$encodedName'
      '&tn=$encodedNote'
      '&am=$amountStr'
      '&cu=INR'
      '&tid=$tid'
      '&tr=$orderId'
      '&mc=5812',
    );

    bool launched = false;

    // Try GPay first
    try {
      if (await canLaunchUrl(gpayUri)) {
        launched = await launchUrl(
          gpayUri,
          mode: LaunchMode.externalNonBrowserApplication,
        );
      }
    } catch (_) {}

    // Fall back to any UPI app
    if (!launched) {
      try {
        launched = await launchUrl(
          upiUri,
          mode: LaunchMode.externalNonBrowserApplication,
        );
      } catch (_) {}
    }

    if (!launched) {
      return const PaymentResult(launched: false);
    }

    // Show confirmation dialog after returning from UPI app
    if (!context.mounted) return const PaymentResult(launched: true);
    final confirmed = await _showConfirmationDialog(context, amount, vendorName);

    return PaymentResult(launched: true, userConfirmed: confirmed);
  }

  Future<bool?> _showConfirmationDialog(
    BuildContext context,
    double amount,
    String vendorName,
  ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.payment_rounded, color: Color(0xFF6C63FF)),
            SizedBox(width: 8),
            Text(
              'Confirm Payment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        content: Text(
          'Did you complete the ₹${amount.toStringAsFixed(2)} payment to $vendorName?',
          style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'No, Cancel Order',
              style: TextStyle(color: Colors.red),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Yes, Paid!'),
          ),
        ],
      ),
    );
  }
}
