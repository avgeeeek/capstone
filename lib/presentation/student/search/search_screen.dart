import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/search_repository.dart';
import '../../../data/models/vendor_model.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state.dart';
import '../home/stall_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  
  List<VendorModel> _stalls = [];
  List<MenuItemModel> _menuItems = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _query = query;
      _isLoading = true;
    });

    if (query.trim().isEmpty) {
      setState(() {
        _stalls = [];
        _menuItems = [];
        _isLoading = false;
      });
      return;
    }

    final searchRepo = context.read<SearchRepository>();
    
    // Execute both searches concurrently
    final results = await Future.wait([
      searchRepo.searchStalls(query),
      searchRepo.searchMenuItems(query),
    ]);

    if (mounted) {
      setState(() {
        _stalls = results[0] as List<VendorModel>;
        _menuItems = results[1] as List<MenuItemModel>;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search stalls, cuisines, or items...',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              fontFamily: 'Inter',
            ),
          ),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
          ),
          onChanged: _performSearch,
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const FullScreenLoader();
    }

    if (_query.isEmpty) {
      return const EmptyState(
        title: 'What are you craving?',
        subtitle: 'Search for stalls, cuisines, or specific menu items',
        icon: Icons.search_rounded,
      );
    }

    if (_stalls.isEmpty && _menuItems.isEmpty) {
      return EmptyState(
        title: 'No results found',
        subtitle: 'We couldn\'t find anything matching "$_query"',
        icon: Icons.search_off_rounded,
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        if (_stalls.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Stalls',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
          ),
          ..._stalls.map((vendor) => Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                child: StallCard(
                  vendor: vendor,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.stallMenu,
                    arguments: vendor,
                  ),
                ),
              )),
          const SizedBox(height: 16),
        ],
        
        if (_menuItems.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Menu Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
          ),
          ..._menuItems.map((item) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    image: item.imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(item.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: item.imageUrl == null
                      ? const Icon(Icons.fastfood_rounded, color: AppColors.textSecondary)
                      : null,
                ),
                title: Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                subtitle: Text(
                  item.category,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
                trailing: Text(
                  '₹${item.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontFamily: 'Inter',
                  ),
                ),
                // Note: Tapping this would ideally go to the stall menu and highlight the item,
                // but for now we don't have the vendor model to pass, so it's view-only in search
                // unless we join the vendor data. A future enhancement.
              )),
        ],
      ],
    );
  }
}
