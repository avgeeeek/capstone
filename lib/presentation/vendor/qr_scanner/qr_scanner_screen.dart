import 'dart:math' as math;
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
                  Navigator.pop(context);
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
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final scanSize = math.min(w * 0.72, 280.0);
          final center = Offset(w / 2, h * 0.42);
          final scanRect = Rect.fromCenter(
            center: center,
            width: scanSize,
            height: scanSize,
          );

          return Stack(
            children: [
              // 1. Camera preview
              Positioned.fill(
                child: MobileScanner(
                  controller: _scannerController,
                  onDetect: _handleBarcode,
                ),
              ),

              // 2. CustomPainter: Dark mask with smooth rounded cutout and matching corner brackets
              Positioned.fill(
                child: CustomPaint(
                  painter: ScannerOverlayPainter(
                    scanRect: scanRect,
                    borderRadius: 22.0,
                    borderLength: 36.0,
                    borderWidth: 5.0,
                    borderColor: AppColors.primary,
                  ),
                ),
              ),

              // 3. Scan line animation inside the frame
              _ScanLine(scanRect: scanRect),

              // 4. Instructional texts positioned clearly below the frame
              Positioned(
                top: scanRect.bottom + 32,
                left: 20,
                right: 20,
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Scan Student\'s QR Code',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Align QR code within the frame to confirm pickup',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),

              // 5. Processing loader
              if (_isProcessing)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Single painter that draws the dark background with the rounded cutout
/// AND the corner brackets at the EXACT same coordinates, eliminating any misalignment.
class ScannerOverlayPainter extends CustomPainter {
  final Rect scanRect;
  final double borderRadius;
  final double borderLength;
  final double borderWidth;
  final Color borderColor;
  final Color overlayColor;

  ScannerOverlayPainter({
    required this.scanRect,
    this.borderRadius = 22.0,
    this.borderLength = 36.0,
    this.borderWidth = 5.0,
    this.borderColor = AppColors.primary,
    this.overlayColor = const Color(0x99000000), // 60% dark overlay
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(scanRect, Radius.circular(borderRadius));

    // 1. Dark mask with transparent cutout
    final bgPaint = Paint()..color = overlayColor;
    final bgPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(bgPath, bgPaint);

    // 2. Subtle translucent inner border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, borderPaint);

    // 3. Four corner brackets drawn exactly along the rounded cutout
    final cornerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final l = scanRect.left;
    final t = scanRect.top;
    final r = scanRect.right;
    final b = scanRect.bottom;
    final rad = borderRadius;
    final len = borderLength;
    const pi = math.pi;

    // Top-Left corner (starts going down left side, wraps around arc, goes right along top)
    final tlPath = Path()
      ..moveTo(l, t + rad + len)
      ..lineTo(l, t + rad)
      ..arcTo(Rect.fromLTWH(l, t, 2 * rad, 2 * rad), pi, pi / 2, false)
      ..lineTo(l + rad + len, t);
    canvas.drawPath(tlPath, cornerPaint);

    // Top-Right corner (starts on top side, wraps arc, goes down right side)
    final trPath = Path()
      ..moveTo(r - rad - len, t)
      ..lineTo(r - rad, t)
      ..arcTo(Rect.fromLTWH(r - 2 * rad, t, 2 * rad, 2 * rad), -pi / 2, pi / 2, false)
      ..lineTo(r, t + rad + len);
    canvas.drawPath(trPath, cornerPaint);

    // Bottom-Right corner (starts on right side, wraps arc, goes left along bottom)
    final brPath = Path()
      ..moveTo(r, b - rad - len)
      ..lineTo(r, b - rad)
      ..arcTo(Rect.fromLTWH(r - 2 * rad, b - 2 * rad, 2 * rad, 2 * rad), 0, pi / 2, false)
      ..lineTo(r - rad - len, b);
    canvas.drawPath(brPath, cornerPaint);

    // Bottom-Left corner (starts on bottom side, wraps arc, goes up left side)
    final blPath = Path()
      ..moveTo(l + rad + len, b)
      ..lineTo(l + rad, b)
      ..arcTo(Rect.fromLTWH(l, b - 2 * rad, 2 * rad, 2 * rad), pi / 2, pi / 2, false)
      ..lineTo(l, b - rad - len);
    canvas.drawPath(blPath, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) =>
      oldDelegate.scanRect != scanRect || oldDelegate.borderColor != borderColor;
}

/// Animated scan line that sweeps top-to-bottom inside the frame.
class _ScanLine extends StatefulWidget {
  final Rect scanRect;
  const _ScanLine({required this.scanRect});

  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final y = widget.scanRect.top + 10 + (widget.scanRect.height - 20) * _anim.value;
        return Positioned(
          top: y,
          left: widget.scanRect.left + 16,
          width: widget.scanRect.width - 32,
          height: 2,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0),
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0),
                ],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        );
      },
    );
  }
}
