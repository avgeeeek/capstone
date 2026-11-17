import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../logic/providers/cart_provider.dart';
import '../../../logic/providers/auth_provider.dart';
import '../../../logic/providers/order_provider.dart';
import '../../../data/repositories/vendor_repository.dart';
import '../../../data/models/vendor_model.dart';
import '../../../data/services/payment_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/api_constants.dart';
import 'payment_method_selector.dart';
import 'order_summary.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = ApiConstants.paymentGpay;
  bool _isPlacingOrder = false;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            OrderSummaryWidget(cart: cart),
            const SizedBox(height: 20),
            // Payment Method
            PaymentMethodSelector(
              selected: _paymentMethod,
              onSelected: (m) => setState(() => _paymentMethod = m),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: _buildPlaceOrderBar(context, cart),
    );
  }

  Widget _buildPlaceOrderBar(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontFamily: 'Inter')),
              Text(
                '₹${cart.total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary, fontFamily: 'Inter'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isPlacingOrder ? null : () => _placeOrder(context, cart),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isPlacingOrder
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : const Text(
                      'Pay with Google Pay',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context, CartProvider cart) async {
    setState(() => _isPlacingOrder = true);
    final auth = context.read<AuthProvider>();
    final orderProvider = context.read<OrderProvider>();
    final paymentService = context.read<PaymentService>();

    // Fetch vendor info (UPI ID + owner ID for notification)
    final vendorRepo = context.read<VendorRepository>();
    VendorModel? vendor;
    try {
      vendor = await vendorRepo.getVendorById(cart.vendorId!);
    } catch (_) {}

    if (!context.mounted) return;

    // ── UPI payment ────────────────────────────────────────────────────────
    final result = await paymentService.launchUpiPayment(
      context: context,
      vendorUpiId: vendor?.upiId ?? cart.vendorUpiId ?? 'campuseats@upi',
      vendorName: cart.vendorName ?? 'Vendor',
      amount: cart.total,
      orderId: 'CE${DateTime.now().millisecondsSinceEpoch}',
      transactionNote: 'CampusEats order from ${cart.vendorName}',
    );

    if (!result.launched) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No UPI app found. Please install Google Pay or PhonePe.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _isPlacingOrder = false);
      }
      return;
    }

    // User cancelled the confirmation dialog
    if (result.userConfirmed != true) {
      if (context.mounted) {
        setState(() => _isPlacingOrder = false);
      }
      return;
    }

    // Payment confirmed — place order in Firestore
    if (!context.mounted) return;

    final orderId = await orderProvider.placeOrder(
      studentId: auth.userId,
      vendorId: cart.vendorId!,
      items: cart.orderItems,
      totalAmount: cart.total,
      paymentMethod: _paymentMethod,
      paymentStatus: ApiConstants.paymentStatusPaid,
      vendorUserId: vendor?.ownerId ?? cart.vendorId!,
      studentName: auth.userName,
      estimatedMinutes: cart.estimatedPrepMinutes,
    );

    setState(() => _isPlacingOrder = false);

    if (!context.mounted) return;
    if (orderId != null) {
      cart.clearCart();
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.orderTracking,
        (r) => r.settings.name == AppRoutes.studentHome,
        arguments: orderId,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.errorMessage ?? 'Failed to place order'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
