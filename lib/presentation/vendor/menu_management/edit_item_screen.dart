import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../logic/providers/vendor_provider.dart';
import '../../../data/repositories/menu_repository.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/services/storage_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';

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
  File? _newImage;
  late bool _isAvailable;
  bool _isSaving = false;

  final List<String> _categories = ['Breakfast', 'Lunch', 'Dinner', 'Snacks', 'Beverages', 'Desserts', 'Other'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item.name);
    _priceCtrl = TextEditingController(text: widget.item.price.toStringAsFixed(0));
    _descCtrl = TextEditingController(text: widget.item.description);
    _selectedCategory = widget.item.category;
    _isAvailable = widget.item.isAvailable;
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        const Text('Available', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                        Text(
                          _isAvailable ? 'Visible to students' : 'Out of Stock',
                          style: TextStyle(
                            fontSize: 12, fontFamily: 'Inter',
                            color: _isAvailable ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isAvailable,
                      activeColor: AppColors.success,
                      onChanged: (v) => setState(() => _isAvailable = v),
                    ),
                  ],
                ),
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
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: _newImage != null
              ? Image.file(_newImage!, fit: BoxFit.cover, width: double.infinity)
              : widget.item.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: widget.item.imageUrl!,
                      fit: BoxFit.cover, width: double.infinity,
                      placeholder: (_, __) => _imagePlaceholder(),
                      errorWidget: (_, __, ___) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
        ),
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

  Future<void> _pickImage() async {
    final storageService = context.read<StorageService>();
    final file = await storageService.pickImage();
    if (file != null) setState(() => _newImage = file);
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      String? imageUrl = widget.item.imageUrl;

      if (_newImage != null) {
        final vendor = context.read<VendorProvider>().vendor;
        if (vendor != null) {
          final storageService = context.read<StorageService>();
          imageUrl = await storageService.uploadMenuImage(_newImage!, vendor.id);
        }
      }

      final menuRepo = context.read<MenuRepository>();
      await menuRepo.updateMenuItem(widget.item.id, {
        'name': _nameCtrl.text.trim(),
        'price': double.parse(_priceCtrl.text.trim()),
        'category': _selectedCategory,
        'description': _descCtrl.text.trim(),
        'imageUrl': imageUrl,
        'isAvailable': _isAvailable,
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
