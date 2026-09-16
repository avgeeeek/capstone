import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../../logic/providers/vendor_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    
    final qrData = barcodes.first.rawValue;
    if (qrData == null || qrData.isEmpty) return;

    if (!qrData.startsWith('campuseats://order/')) {
       // Not a valid order QR
       return;
    }

    setState(() => _isProcessing = true);
    
    final vendor = context.read<VendorProvider>();
    final order = await vendor.getOrderByQrData(qrData);

    if (!mounted) return;

    if (order == null) {
      _showError('Order not found');
      setState(() => _isProcessing = false);
      return;
    }

    if (order.vendorId != vendor.vendor?.id) {
      _showError('This order belongs to a different stall');
      setState(() => _isProcessing = false);
      return;
    }

    if (order.status == ApiConstants.statusPickedUp) {
      _showError('This order has already been picked up');
      setState(() => _isProcessing = false);
      return;
    }

    if (order.status != ApiConstants.statusReady) {
      _showError('This order is not ready for pickup yet (Status: ${order.status})');
      setState(() => _isProcessing = false);
      return;
    }

    // Valid order ready for pickup
    _showConfirmDialog(order.id, order.studentId);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showConfirmDialog(String orderId, String studentId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.success),
            SizedBox(width: 8),
            Text('Confirm Pickup'),
          ],
        ),
        content: Text('Order #${orderId.substring(0, 8).toUpperCase()} is ready.\nConfirm pickup?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isProcessing = false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final vendor = context.read<VendorProvider>();
              final success = await vendor.confirmPickup(orderId);
              
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pickup confirmed!'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context); // Go back to dashboard
                } else {
                  _showError('Failed to confirm pickup');
                  setState(() => _isProcessing = false);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleBarcode,
          ),
          // Scanner Overlay
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: AppColors.primary,
                borderRadius: 20,
                borderLength: 40,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.7,
              ),
            ),
          ),
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Scan Student\'s QR Code',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                ),
                SizedBox(height: 8),
                Text(
                  'Align QR code within the frame to confirm pickup',
                  style: TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Inter'),
                ),
              ],
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 3.0,
    this.borderRadius = 0,
    this.borderLength = 20,
    required this.cutOutSize,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRect(rect)
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: rect.center, width: cutOutSize, height: cutOutSize),
        Radius.circular(borderRadius),
      ));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final borderLength2 = borderLength > cutOutSize / 2 ? cutOutSize / 2 : borderLength;
    final cutOut = cutOutSize;

    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawPath(
      Path()
        ..moveTo(width / 2 - cutOut / 2, height / 2 - cutOut / 2 + borderLength2)
        ..lineTo(width / 2 - cutOut / 2, height / 2 - cutOut / 2 + borderRadius)
        ..quadraticBezierTo(width / 2 - cutOut / 2, height / 2 - cutOut / 2, width / 2 - cutOut / 2 + borderRadius, height / 2 - cutOut / 2)
        ..lineTo(width / 2 - cutOut / 2 + borderLength2, height / 2 - cutOut / 2),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(width / 2 + cutOut / 2, height / 2 - cutOut / 2 + borderLength2)
        ..lineTo(width / 2 + cutOut / 2, height / 2 - cutOut / 2 + borderRadius)
        ..quadraticBezierTo(width / 2 + cutOut / 2, height / 2 - cutOut / 2, width / 2 + cutOut / 2 - borderRadius, height / 2 - cutOut / 2)
        ..lineTo(width / 2 + cutOut / 2 - borderLength2, height / 2 - cutOut / 2),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(width / 2 - cutOut / 2, height / 2 + cutOut / 2 - borderLength2)
        ..lineTo(width / 2 - cutOut / 2, height / 2 + cutOut / 2 - borderRadius)
        ..quadraticBezierTo(width / 2 - cutOut / 2, height / 2 + cutOut / 2, width / 2 - cutOut / 2 + borderRadius, height / 2 + cutOut / 2)
        ..lineTo(width / 2 - cutOut / 2 + borderLength2, height / 2 + cutOut / 2),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(width / 2 + cutOut / 2, height / 2 + cutOut / 2 - borderLength2)
        ..lineTo(width / 2 + cutOut / 2, height / 2 + cutOut / 2 - borderRadius)
        ..quadraticBezierTo(width / 2 + cutOut / 2, height / 2 + cutOut / 2, width / 2 + cutOut / 2 - borderRadius, height / 2 + cutOut / 2)
        ..lineTo(width / 2 + cutOut / 2 - borderLength2, height / 2 + cutOut / 2),
      paint,
    );

    final bgPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;
      
    final bgPath = Path()
      ..addRect(rect)
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: rect.center, width: cutOutSize, height: cutOutSize),
        Radius.circular(borderRadius),
      ))
      ..fillType = PathFillType.evenOdd;
      
    canvas.drawPath(bgPath, bgPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      borderRadius: borderRadius * t,
      borderLength: borderLength * t,
      cutOutSize: cutOutSize * t,
    );
  }
}
