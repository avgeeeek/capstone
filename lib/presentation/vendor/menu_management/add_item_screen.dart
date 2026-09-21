import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../logic/providers/vendor_provider.dart';
import '../../../data/repositories/menu_repository.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  bool _isAvailable = true;
  bool _isSaving = false;

  final List<String> _categories = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snacks',
    'Beverages',
    'Desserts',
    'Other'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Menu Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNoImageBanner(),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Item Name',
                hint: 'e.g. Masala Dosa',
                controller: _nameCtrl,
                validator: Validators.validateName,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Price (₹)',
                hint: 'e.g. 60',
                controller: _priceCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: Validators.validatePrice,
              ),
              const SizedBox(height: 14),
              // Category dropdown
              DropdownButtonFormField<String>(
                initialValue:
                    _categoryCtrl.text.isNotEmpty ? _categoryCtrl.text : null,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                validator: (v) => v == null ? 'Category is required' : null,
                onChanged: (v) => _categoryCtrl.text = v ?? '',
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Description',
                hint: 'Describe the item...',
                controller: _descCtrl,
                maxLines: 3,
                validator: (v) => null,
              ),
              const SizedBox(height: 14),
              // Availability switch
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Available',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter')),
                        Text(
                          _isAvailable
                              ? 'Visible to students'
                              : 'Hidden (Out of Stock)',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Inter',
                            color: _isAvailable
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isAvailable,
                      activeThumbColor: AppColors.success,
                      onChanged: (v) => setState(() => _isAvailable = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              CustomButton(
                text: 'Add Item',
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _saveItem,
                prefixIcon: Icons.add_circle_rounded,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoImageBanner() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3), width: 2),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_outlined,
              color: AppColors.primary, size: 32),
          SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('No image upload',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter')),
              Text('Items use a default food icon',
                  style: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                      fontFamily: 'Inter')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final vendor = context.read<VendorProvider>().vendor;
    if (vendor == null) return;
    final menuRepo = context.read<MenuRepository>();

    try {
      const String? imageUrl =
          null; // No image upload — Firebase Storage requires Blaze plan

      final item = MenuItemModel(
        id: '',
        vendorId: vendor.id,
        name: _nameCtrl.text.trim(),
        price: double.parse(_priceCtrl.text.trim()),
        category: _categoryCtrl.text,
        description: _descCtrl.text.trim(),
        imageUrl: imageUrl,
        isAvailable: _isAvailable,
        rating: 0.0,
      );

      await menuRepo.addMenuItem(item);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Item added!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
