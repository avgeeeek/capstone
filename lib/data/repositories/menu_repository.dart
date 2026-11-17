import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item_model.dart';
import '../../core/constants/api_constants.dart';

class MenuRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<MenuItemModel>> getMenuItemsForVendor(String vendorId) {
    return _db
        .collection(ApiConstants.menuItemsCollection)
        .where('vendorId', isEqualTo: vendorId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => MenuItemModel.fromSnapshot(doc)).toList());
  }

  Future<List<MenuItemModel>> getMenuItemsOnce(String vendorId) async {
    final snap = await _db
        .collection(ApiConstants.menuItemsCollection)
        .where('vendorId', isEqualTo: vendorId)
        .get();
    return snap.docs.map((doc) => MenuItemModel.fromSnapshot(doc)).toList();
  }

  Future<String> addMenuItem(MenuItemModel item) async {
    final ref = await _db
        .collection(ApiConstants.menuItemsCollection)
        .add(item.toMap());
    return ref.id;
  }

  Future<void> updateMenuItem(String itemId, Map<String, dynamic> data) async {
    await _db
        .collection(ApiConstants.menuItemsCollection)
        .doc(itemId)
        .update(data);
  }

  Future<void> deleteMenuItem(String itemId) async {
    await _db
        .collection(ApiConstants.menuItemsCollection)
        .doc(itemId)
        .delete();
  }

  Future<void> toggleAvailability(String itemId, bool isAvailable) async {
    await _db
        .collection(ApiConstants.menuItemsCollection)
        .doc(itemId)
        .update({'isAvailable': isAvailable});
  }

  /// Set the tracked stock count for an item.
  Future<void> updateStockCount(String itemId, int? stockCount) async {
    final count = (stockCount ?? 0).clamp(0, 99999);
    await _db
        .collection(ApiConstants.menuItemsCollection)
        .doc(itemId)
        .update({
      'stockCount': count,
      'isAvailable': count > 0,
    });
  }

  /// Called when an order is placed — atomically decrements stock for each
  /// ordered item. If any item's stock hits 0, it is auto-marked unavailable.
  Future<void> batchDecrementStock(
    List<({String itemId, int quantity})> orderedItems,
  ) async {
    try {
      await _db.runTransaction((tx) async {
        for (final entry in orderedItems) {
          final ref = _db
              .collection(ApiConstants.menuItemsCollection)
              .doc(entry.itemId);
          final snap = await tx.get(ref);
          if (!snap.exists) continue;
          final data = snap.data()!;
          final currentStock = (data['stockCount'] as num?)?.toInt() ?? 20;
          final newStock = (currentStock - entry.quantity).clamp(0, 99999);
          final updates = <String, dynamic>{
            'stockCount': newStock,
            if (newStock <= 0) 'isAvailable': false,
          };
          tx.update(ref, updates);
        }
      });
    } catch (_) {
      // Fallback direct updates if transaction aborts
      for (final entry in orderedItems) {
        try {
          final ref = _db
              .collection(ApiConstants.menuItemsCollection)
              .doc(entry.itemId);
          final snap = await ref.get();
          if (!snap.exists) continue;
          final data = snap.data()!;
          final currentStock = (data['stockCount'] as num?)?.toInt() ?? 20;
          final newStock = (currentStock - entry.quantity).clamp(0, 99999);
          await ref.update({
            'stockCount': newStock,
            if (newStock <= 0) 'isAvailable': false,
          });
        } catch (_) {}
      }
    }
  }

  Future<MenuItemModel?> getMenuItemById(String itemId) async {
    final doc = await _db
        .collection(ApiConstants.menuItemsCollection)
        .doc(itemId)
        .get();
    if (!doc.exists) return null;
    return MenuItemModel.fromSnapshot(doc);
  }

  Future<List<String>> getCategoriesForVendor(String vendorId) async {
    final items = await getMenuItemsOnce(vendorId);
    return items.map((i) => i.category).toSet().toList();
  }
}
