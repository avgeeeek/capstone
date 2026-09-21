import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../models/vendor_model.dart';
import '../../core/constants/api_constants.dart';

class AdminRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Users ──

  Stream<List<UserModel>> getAllUsers() {
    return _db
        .collection(ApiConstants.usersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => UserModel.fromSnapshot(doc)).toList());
  }

  Stream<List<UserModel>> getUsersByRole(String role) {
    return _db
        .collection(ApiConstants.usersCollection)
        .where('role', isEqualTo: role)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => UserModel.fromSnapshot(doc)).toList());
  }

  Future<void> deactivateUser(String uid) async {
    await _db
        .collection(ApiConstants.usersCollection)
        .doc(uid)
        .update({'isApproved': false});
  }

  Future<void> activateUser(String uid) async {
    await _db
        .collection(ApiConstants.usersCollection)
        .doc(uid)
        .update({'isApproved': true});
  }

  Future<void> deleteUser(String uid) async {
    await _db.collection(ApiConstants.usersCollection).doc(uid).delete();
  }

  // ── Orders ──

  Stream<List<OrderModel>> getAllOrders() {
    return _db
        .collection(ApiConstants.ordersCollection)
        .orderBy('placedAt', descending: true)
        .limit(200)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => OrderModel.fromSnapshot(doc)).toList());
  }

  Future<Map<String, dynamic>> getOrderStats() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final allSnap = await _db.collection(ApiConstants.ordersCollection).get();
    final allOrders =
        allSnap.docs.map((doc) => OrderModel.fromSnapshot(doc)).toList();

    final todayOrders =
        allOrders.where((o) => o.placedAt.isAfter(todayStart)).toList();
    final completedOrders =
        allOrders.where((o) => o.status == ApiConstants.statusPickedUp).toList();
    final todayRevenue = todayOrders
        .where((o) => o.status == ApiConstants.statusPickedUp)
        .fold(0.0, (acc, o) => acc + o.totalAmount);
    final totalRevenue =
        completedOrders.fold(0.0, (acc, o) => acc + o.totalAmount);
    final pendingCount =
        allOrders.where((o) => o.status == ApiConstants.statusPending).length;

    return {
      'totalOrders': allOrders.length,
      'todayOrders': todayOrders.length,
      'completedOrders': completedOrders.length,
      'pendingCount': pendingCount,
      'todayRevenue': todayRevenue,
      'totalRevenue': totalRevenue,
    };
  }

  // ── Vendors ──

  Stream<List<VendorModel>> getAllVendors() {
    return _db
        .collection(ApiConstants.vendorsCollection)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => VendorModel.fromSnapshot(doc)).toList());
  }

  Future<void> deactivateVendor(String vendorId, String ownerId) async {
    // Deactivate vendor stall
    await _db
        .collection(ApiConstants.vendorsCollection)
        .doc(vendorId)
        .update({'isActive': false, 'isOpen': false});

    // Also deactivate the owner's user account
    await deactivateUser(ownerId);
  }

  Future<void> activateVendor(String vendorId, String ownerId) async {
    await _db
        .collection(ApiConstants.vendorsCollection)
        .doc(vendorId)
        .update({'isActive': true});

    await activateUser(ownerId);
  }

  Future<void> deleteVendor(String vendorId, String ownerId) async {
    // Delete all menu items for this vendor
    final menuSnap = await _db
        .collection(ApiConstants.menuItemsCollection)
        .where('vendorId', isEqualTo: vendorId)
        .get();
    final batch = _db.batch();
    for (final doc in menuSnap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    // Delete vendor
    await _db.collection(ApiConstants.vendorsCollection).doc(vendorId).delete();

    // Delete user
    await deleteUser(ownerId);
  }
}
