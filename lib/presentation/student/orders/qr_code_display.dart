import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';

class QrCodeDisplay extends StatelessWidget {
  final String qrData;
  final String orderId;

  const QrCodeDisplay({super.key, required this.qrData, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withOpacity(0.4), width: 2),
        boxShadow: [BoxShadow(color: AppColors.success.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.qr_code_2_rounded, color: AppColors.success, size: 22),
              SizedBox(width: 8),
              Text(
                'Pickup QR Code',
                style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: AppColors.success, fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Show this to the vendor to confirm pickup',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Inter'),
          ),
          const SizedBox(height: 16),
          QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 200,
            backgroundColor: Colors.white,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: AppColors.textPrimary,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Order #${orderId.substring(0, 8).toUpperCase()}',
              style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: AppColors.primary, fontFamily: 'Inter',
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
