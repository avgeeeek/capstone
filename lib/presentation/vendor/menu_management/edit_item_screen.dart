import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/repositories/menu_repository.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import 'inventory_widgets.dart';

class EditItemScreen extends StatefulWidget {
  final MenuItemModel item;
  const EditItemScreen({super.key, required this.item});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _descCtrl;
  late String _selectedCategory;
  bool _isSaving = false;

  // Inventory
  late int _stockCount;
  late int _prepMinutes;

  final List<String> _categories = ['Breakfast', 'Lunch', 'Dinner', 'Snacks', 'Beverages', 'Desserts', 'Other'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item.name);
    _priceCtrl = TextEditingController(text: widget.item.price.toStringAsFixed(0));
    _descCtrl = TextEditingController(text: widget.item.description);
    _selectedCategory = widget.item.category;
    _stockCount = widget.item.stockCount ?? 20;
    _prepMinutes = widget.item.estimatedMinutes ?? 15;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Menu Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Item Name',
                controller: _nameCtrl,
                validator: Validators.validateName,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Price (₹)',
                controller: _priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: Validators.validatePrice,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _categories.contains(_selectedCategory) ? _selectedCategory : _categories.first,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v ?? _selectedCategory),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Description',
                controller: _descCtrl,
                maxLines: 3,
              ),
              const SizedBox(height: 14),
              // Inventory tracking card
              InventoryCard(
                stockCount: _stockCount,
                onChangeCount: (v) => setState(() => _stockCount = v),
              ),
              const SizedBox(height: 14),
              // Preparation time card
              PrepTimeCard(
                minutes: _prepMinutes,
                onChanged: (v) => setState(() => _prepMinutes = v),
              ),
              const SizedBox(height: 28),
              CustomButton(
                text: 'Save Changes',
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _saveChanges,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: widget.item.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: widget.item.imageUrl!,
                fit: BoxFit.cover, width: double.infinity,
                placeholder: (_, __) => _imagePlaceholder(),
                errorWidget: (_, __, ___) => _imagePlaceholder(),
              )
            : _imagePlaceholder(),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
    height: 180, color: AppColors.primaryLight,
    child: const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_rounded, color: AppColors.primary, size: 40),
        SizedBox(height: 6),
        Text('Tap to change image', style: TextStyle(color: AppColors.primary, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
      ],
    ),
  );


  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      // Keep existing imageUrl unchanged — no upload (Firebase Storage requires Blaze plan)
      final String? imageUrl = widget.item.imageUrl;
      final menuRepo = context.read<MenuRepository>();

      await menuRepo.updateMenuItem(widget.item.id, {
        'name': _nameCtrl.text.trim(),
        'price': double.parse(_priceCtrl.text.trim()),
        'category': _selectedCategory,
        'description': _descCtrl.text.trim(),
        'imageUrl': imageUrl,
        'isAvailable': _stockCount > 0,
        'stockCount': _stockCount,
        'estimatedMinutes': _prepMinutes,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item updated!'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
