import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/vendor_model.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/repositories/menu_repository.dart';
import '../../../logic/providers/cart_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state.dart';
import 'menu_item_card.dart';
import 'category_chip.dart';
import 'item_detail_bottom_sheet.dart';

class MenuScreen extends StatefulWidget {
  final VendorModel vendor;
  const MenuScreen({super.key, required this.vendor});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final menuRepo = context.read<MenuRepository>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.vendor.stallName,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              background: widget.vendor.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: widget.vendor.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _heroBg(),
                      errorWidget: (_, __, ___) => _heroBg(),
                    )
                  : _heroBg(),
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      top: 6, right: 6,
                      child: Container(
                        width: 16, height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary, shape: BoxShape.circle),
                        child: Center(
                          child: Text('${cart.itemCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
        body: StreamBuilder<List<MenuItemModel>>(
          stream: menuRepo.getMenuItemsForVendor(widget.vendor.id),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const MenuShimmerGrid();
            }
            if (snap.hasError) {
              return Center(child: Text('Error: ${snap.error}'));
            }
            final items = snap.data ?? [];
            if (items.isEmpty) {
              return const EmptyState(
                title: 'No items available',
                subtitle: 'This stall has no menu items yet',
                icon: Icons.restaurant_menu_rounded,
              );
            }

            // Build categories
            final categories = ['All', ...{...items.map((i) => i.category)}];
            final filtered = _selectedCategory == 'All'
                ? items
                : items.where((i) => i.category == _selectedCategory).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category chips
                SizedBox(
                  height: 52,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CategoryChip(
                        label: categories[i],
                        isSelected: categories[i] == _selectedCategory,
                        onTap: () => setState(() => _selectedCategory = categories[i]),
                      ),
                    ),
                  ),
                ),
                // Items grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => MenuItemCard(
                      item: filtered[i],
                      vendor: widget.vendor,
                      onTap: () => _showItemDetail(context, filtered[i]),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      // Floating cart button
      bottomNavigationBar: cart.isEmpty || cart.vendorId != widget.vendor.id
          ? null
          : _buildCartBar(context, cart),
    );
  }

  Widget _heroBg() => Container(
    color: AppColors.primaryLight,
    child: Center(
      child: Text(
        widget.vendor.stallName.isNotEmpty ? widget.vendor.stallName[0] : '🍽️',
        style: const TextStyle(fontSize: 60, fontWeight: FontWeight.w800, color: AppColors.primary),
      ),
    ),
  );

  void _showItemDetail(BuildContext context, MenuItemModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ItemDetailBottomSheet(item: item, vendor: widget.vendor),
    );
  }

  Widget _buildCartBar(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${cart.itemCount} items',
                style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter'),
              ),
            ),
            const Text('View Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
            Text('₹${cart.total.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, fontFamily: 'Inter')),
          ],
        ),
      ),
    );
  }
}
