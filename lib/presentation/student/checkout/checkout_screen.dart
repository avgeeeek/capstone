import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../logic/providers/cart_provider.dart';
import '../../../logic/providers/auth_provider.dart';
import '../../../logic/providers/order_provider.dart';
import '../../../logic/providers/vendor_provider.dart';
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
  String _paymentMethod = ApiConstants.paymentCash;
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
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, -2))],
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
                  : Text(
                      _paymentMethod == ApiConstants.paymentGpay ? 'Pay with Google Pay' : 'Place Order (Cash)',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
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

    // Fetch vendor info to get owner userId for notification
    final vendorRepo = context.read<VendorRepository>();
    VendorModel? vendor;
    try {
      vendor = await vendorRepo.getVendorById(cart.vendorId!);
    } catch (_) {}

    String paymentStatus = ApiConstants.paymentStatusPending;

    // Handle GPay
    if (_paymentMethod == ApiConstants.paymentGpay) {
      final launched = await paymentService.launchGooglePay(
        vendorUpiId: cart.vendorUpiId ?? 'campuseats@upi',
        vendorName: cart.vendorName ?? 'Vendor',
        amount: cart.total,
        orderId: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        transactionNote: 'Order from ${cart.vendorName}',
      );

      if (!launched) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google Pay not available. Please install GPay or use Cash.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          setState(() => _isPlacingOrder = false);
          return;
        }
      }

      // Ask user to confirm payment was completed
      if (mounted) {
        final confirmed = await paymentService.showPaymentConfirmationDialog(context);
        paymentStatus = confirmed
            ? ApiConstants.paymentStatusPaid
            : ApiConstants.paymentStatusPending;
      }
    }

    if (!mounted) return;

    // Place order
    final orderId = await orderProvider.placeOrder(
      studentId: auth.userId,
      vendorId: cart.vendorId!,
      items: cart.orderItems,
      totalAmount: cart.total,
      paymentMethod: _paymentMethod,
      paymentStatus: paymentStatus,
      vendorUserId: vendor?.ownerId ?? cart.vendorId!,
      studentName: auth.userName,
    );

    setState(() => _isPlacingOrder = false);

    if (!mounted) return;
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
