import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../logic/providers/auth_provider.dart';
import '../../../logic/providers/vendor_provider.dart';
import '../../../data/repositories/vendor_repository.dart';
import '../../../data/models/vendor_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';

class VendorOnboardingScreen extends StatefulWidget {
  const VendorOnboardingScreen({super.key});

  @override
  State<VendorOnboardingScreen> createState() => _VendorOnboardingScreenState();
}

class _VendorOnboardingScreenState extends State<VendorOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stallNameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _upiCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final List<String> _selectedCuisines = [];
  bool _isSaving = false;

  final List<String> _cuisineOptions = [
    'South Indian',
    'North Indian',
    'Chinese',
    'Fast Food',
    'Beverages',
    'Snacks',
    'Sweets',
    'Continental',
  ];

  @override
  void dispose() {
    _stallNameCtrl.dispose();
    _locationCtrl.dispose();
    _upiCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveStall() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCuisines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one cuisine type'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final auth = context.read<AuthProvider>();
    final vendorRepo = context.read<VendorRepository>();
    final vendorProvider = context.read<VendorProvider>();

    try {
      final vendor = VendorModel(
        id: '',
        ownerId: auth.userId,
        stallName: _stallNameCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        cuisine: List.from(_selectedCuisines),
        upiId: _upiCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        isOpen: false,
        rating: 0.0,
        imageUrl: null,
      );

      await vendorRepo.createVendor(vendor);
      await vendorProvider.loadVendorByOwnerId(auth.userId);

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.vendorDashboard, (r) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Set Up Your Stall'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Text('🏪', style: TextStyle(fontSize: 36)),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, Vendor!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Inter',
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tell us about your stall to get started',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Stall Name
                const _SectionLabel(label: '📝 Stall Details'),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Stall Name',
                  hint: 'e.g. Spice Garden',
                  controller: _stallNameCtrl,
                  validator: Validators.validateStallName,
                  prefixIcon:
                      const Icon(Icons.store_outlined, color: AppColors.textHint),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Location / Stall Number',
                  hint: 'e.g. Block A, Stall 3',
                  controller: _locationCtrl,
                  validator: (v) =>
                      Validators.validateRequired(v, 'Location'),
                  prefixIcon: const Icon(Icons.location_on_outlined,
                      color: AppColors.textHint),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Phone Number',
                  hint: '9876543210',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhone,
                  prefixIcon: const Icon(Icons.phone_outlined,
                      color: AppColors.textHint),
                ),
                const SizedBox(height: 24),

                // Cuisine
                const _SectionLabel(label: '🍽️ Cuisine Types'),
                const SizedBox(height: 4),
                const Text(
                  'Select all that apply',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                      fontFamily: 'Inter'),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _cuisineOptions.map((cuisine) {
                    final isSelected = _selectedCuisines.contains(cuisine);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (isSelected) {
                          _selectedCuisines.remove(cuisine);
                        } else {
                          _selectedCuisines.add(cuisine);
                        }
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          cuisine,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Payment
                const _SectionLabel(label: '💳 Payment Settings'),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'UPI ID (for Google Pay)',
                  hint: 'yourstall@okicici',
                  controller: _upiCtrl,
                  validator: Validators.validateUpiId,
                  prefixIcon: const Icon(Icons.payment_rounded,
                      color: AppColors.textHint),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: AppColors.primary, size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Students will use this UPI ID to pay you via Google Pay',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontFamily: 'Inter',
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                CustomButton(
                  text: 'Launch My Stall 🚀',
                  onPressed: _isSaving ? null : _saveStall,
                  isLoading: _isSaving,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontFamily: 'Inter',
      ),
    );
  }
}
