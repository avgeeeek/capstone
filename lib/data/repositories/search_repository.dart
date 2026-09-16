import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vendor_model.dart';
import '../models/menu_item_model.dart';
import '../../core/constants/api_constants.dart';

class SearchRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Search stalls by name or cuisine (client-side filtering)
  Future<List<VendorModel>> searchStalls(String query) async {
    if (query.trim().isEmpty) return [];

    final snap = await _db
        .collection(ApiConstants.vendorsCollection)
        .where('isActive', isEqualTo: true)
        .get();

    final q = query.toLowerCase();
    return snap.docs
        .map((doc) => VendorModel.fromSnapshot(doc))
        .where((v) =>
            v.stallName.toLowerCase().contains(q) ||
            v.cuisine.any((c) => c.toLowerCase().contains(q)) ||
            v.location.toLowerCase().contains(q))
        .toList();
  }

  /// Search menu items by name, category, or description (client-side filtering)
  Future<List<MenuItemModel>> searchMenuItems(String query) async {
    if (query.trim().isEmpty) return [];

    final snap = await _db
        .collection(ApiConstants.menuItemsCollection)
        .get();

    final q = query.toLowerCase();
    return snap.docs
        .map((doc) => MenuItemModel.fromSnapshot(doc))
        .where((item) =>
            item.name.toLowerCase().contains(q) ||
            item.category.toLowerCase().contains(q) ||
            item.description.toLowerCase().contains(q))
        .toList();
  }
}
