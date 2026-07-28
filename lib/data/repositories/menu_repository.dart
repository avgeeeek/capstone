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
