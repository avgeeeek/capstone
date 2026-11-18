import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../../core/constants/api_constants.dart';

class OrderRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> placeOrder(OrderModel order) async {
    final ref =
        _db.collection(ApiConstants.ordersCollection).doc(order.id);
    await ref.set(order.toMap());
    return order.id;
  }

  Future<void> updateOrderStatus(String orderId, String status,
      {Map<String, dynamic>? extraData}) async {
    final data = {'status': status, ...?extraData};
    await _db
        .collection(ApiConstants.ordersCollection)
        .doc(orderId)
        .update(data);
  }

  Future<void> acceptOrder(
    String orderId,
    int estimatedMinutes,
    DateTime estimatedReadyAt,
  ) async {
    await _db
        .collection(ApiConstants.ordersCollection)
        .doc(orderId)
        .update({
      'status': ApiConstants.statusPreparing,
      'estimatedMinutes': estimatedMinutes,
      'estimatedReadyAt': Timestamp.fromDate(estimatedReadyAt),
      'acceptedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> markReady(String orderId) async {
    await _db
        .collection(ApiConstants.ordersCollection)
        .doc(orderId)
        .update({
      'status': ApiConstants.statusReady,
      'readyAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> confirmPickup(String orderId) async {
    await _db
        .collection(ApiConstants.ordersCollection)
        .doc(orderId)
        .update({
      'status': ApiConstants.statusPickedUp,
      'pickedUpAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> rejectOrder(String orderId, {String? reason}) async {
    await _db
        .collection(ApiConstants.ordersCollection)
        .doc(orderId)
        .update({
      'status': ApiConstants.statusRejected,
      'rejectionReason': reason,
    });
  }

  Future<void> cancelOrder(String orderId, {String? reason}) async {
    await _db
        .collection(ApiConstants.ordersCollection)
        .doc(orderId)
        .update({
      'status': ApiConstants.statusCancelled,
      'cancellationReason': reason,
      'cancelledAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> updatePaymentStatus(String orderId, String paymentStatus) async {
    await _db
        .collection(ApiConstants.ordersCollection)
        .doc(orderId)
        .update({'paymentStatus': paymentStatus});
  }

  Stream<OrderModel?> orderStream(String orderId) {
    return _db
        .collection(ApiConstants.ordersCollection)
        .doc(orderId)
        .snapshots()
        .map((doc) =>
            doc.exists ? OrderModel.fromSnapshot(doc) : null);
  }

  Stream<List<OrderModel>> studentOrdersStream(String studentId) {
    return _db
        .collection(ApiConstants.ordersCollection)
        .where('studentId', isEqualTo: studentId)
        .orderBy('placedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => OrderModel.fromSnapshot(doc)).toList());
  }

  Stream<List<OrderModel>> vendorOrdersStream(String vendorId) {
    return _db
        .collection(ApiConstants.ordersCollection)
        .where('vendorId', isEqualTo: vendorId)
        .orderBy('placedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => OrderModel.fromSnapshot(doc)).toList());
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    final doc = await _db
        .collection(ApiConstants.ordersCollection)
        .doc(orderId)
        .get();
    if (!doc.exists) return null;
    return OrderModel.fromSnapshot(doc);
  }

  Future<List<OrderModel>> getVendorOrdersByStatus(
      String vendorId, String status) async {
    final snap = await _db
        .collection(ApiConstants.ordersCollection)
        .where('vendorId', isEqualTo: vendorId)
        .where('status', isEqualTo: status)
        .get();
    return snap.docs.map((doc) => OrderModel.fromSnapshot(doc)).toList();
  }

  /// Seed data: add 3 vendors + 20 menu items to Firestore
  Future<void> seedData(String vendorUserId1, String vendorUserId2, String vendorUserId3) async {
    final batch = _db.batch();

    // Vendor 1
    const v1Id = 'vendor_001';
    batch.set(_db.collection('vendors').doc(v1Id), {
      'stallName': 'Spice Garden',
      'ownerId': vendorUserId1,
      'upiId': 'spicegarden@okicici',
      'cuisine': ['South Indian', 'North Indian'],
      'isOpen': true,
      'rating': 4.5,
      'imageUrl': null,
      'location': 'Block A, Ground Floor',
      'phone': '9876543210',
    });

    // Vendor 2
    const v2Id = 'vendor_002';
    batch.set(_db.collection('vendors').doc(v2Id), {
      'stallName': 'QuickBites',
      'ownerId': vendorUserId2,
      'upiId': 'quickbites@okhdfc',
      'cuisine': ['Fast Food', 'Snacks'],
      'isOpen': true,
      'rating': 4.2,
      'imageUrl': null,
      'location': 'Block B, First Floor',
      'phone': '9876543211',
    });

    // Vendor 3
    const v3Id = 'vendor_003';
    batch.set(_db.collection('vendors').doc(v3Id), {
      'stallName': 'Café Brew',
      'ownerId': vendorUserId3,
      'upiId': 'cafebrew@oksbi',
      'cuisine': ['Beverages', 'Sandwiches'],
      'isOpen': true,
      'rating': 4.7,
      'imageUrl': null,
      'location': 'Block C, Ground Floor',
      'phone': '9876543212',
    });

    await batch.commit();

    // Menu items
    final menuItems = [
      // Spice Garden
      {'vendorId': v1Id, 'name': 'Masala Dosa', 'price': 60.0, 'category': 'Breakfast', 'description': 'Crispy dosa with spicy potato filling', 'isAvailable': true, 'rating': 4.6, 'estimatedMinutes': 12, 'stockCount': 25},
      {'vendorId': v1Id, 'name': 'Idli Sambar', 'price': 40.0, 'category': 'Breakfast', 'description': 'Soft idlis with hot sambar and chutney', 'isAvailable': true, 'rating': 4.4, 'estimatedMinutes': 8, 'stockCount': 30},
      {'vendorId': v1Id, 'name': 'Chole Bhature', 'price': 80.0, 'category': 'Lunch', 'description': 'Spiced chickpeas with fluffy fried bread', 'isAvailable': true, 'rating': 4.8, 'estimatedMinutes': 15, 'stockCount': 20},
      {'vendorId': v1Id, 'name': 'Dal Tadka', 'price': 70.0, 'category': 'Lunch', 'description': 'Tempered yellow lentils with rice', 'isAvailable': true, 'rating': 4.3, 'estimatedMinutes': 15, 'stockCount': 20},
      {'vendorId': v1Id, 'name': 'Paneer Butter Masala', 'price': 120.0, 'category': 'Lunch', 'description': 'Rich creamy tomato-based paneer curry', 'isAvailable': true, 'rating': 4.7, 'estimatedMinutes': 20, 'stockCount': 15},
      {'vendorId': v1Id, 'name': 'Veg Thali', 'price': 100.0, 'category': 'Lunch', 'description': 'Complete meal with dal, sabzi, roti, rice & dessert', 'isAvailable': true, 'rating': 4.5, 'estimatedMinutes': 20, 'stockCount': 15},
      {'vendorId': v1Id, 'name': 'Upma', 'price': 35.0, 'category': 'Breakfast', 'description': 'Semolina porridge with vegetables', 'isAvailable': false, 'rating': 4.0, 'estimatedMinutes': 10, 'stockCount': 0},

      // QuickBites
      {'vendorId': v2Id, 'name': 'Veg Burger', 'price': 75.0, 'category': 'Snacks', 'description': 'Crispy veg patty with fresh veggies and sauce', 'isAvailable': true, 'rating': 4.2, 'estimatedMinutes': 15, 'stockCount': 20},
      {'vendorId': v2Id, 'name': 'French Fries', 'price': 50.0, 'category': 'Snacks', 'description': 'Golden crispy fries with ketchup', 'isAvailable': true, 'rating': 4.5, 'estimatedMinutes': 10, 'stockCount': 30},
      {'vendorId': v2Id, 'name': 'Pav Bhaji', 'price': 70.0, 'category': 'Snacks', 'description': 'Mumbai-style spiced veggie mash with buttered buns', 'isAvailable': true, 'rating': 4.6, 'estimatedMinutes': 15, 'stockCount': 25},
      {'vendorId': v2Id, 'name': 'Samosa', 'price': 20.0, 'category': 'Snacks', 'description': 'Crispy fried pastry with spiced potato filling', 'isAvailable': true, 'rating': 4.4, 'estimatedMinutes': 5, 'stockCount': 40},
      {'vendorId': v2Id, 'name': 'Chicken Roll', 'price': 90.0, 'category': 'Snacks', 'description': 'Spiced chicken wrapped in a paratha', 'isAvailable': true, 'rating': 4.7, 'estimatedMinutes': 15, 'stockCount': 15},
      {'vendorId': v2Id, 'name': 'Maggi', 'price': 40.0, 'category': 'Snacks', 'description': 'Classic instant noodles with masala', 'isAvailable': true, 'rating': 4.1, 'estimatedMinutes': 10, 'stockCount': 50},
      {'vendorId': v2Id, 'name': 'Spring Roll', 'price': 55.0, 'category': 'Snacks', 'description': 'Crispy rolls stuffed with veggies', 'isAvailable': false, 'rating': 4.3, 'estimatedMinutes': 12, 'stockCount': 0},

      // Café Brew
      {'vendorId': v3Id, 'name': 'Filter Coffee', 'price': 30.0, 'category': 'Beverages', 'description': 'Strong South Indian filter coffee with milk', 'isAvailable': true, 'rating': 4.8, 'estimatedMinutes': 5, 'stockCount': 50},
      {'vendorId': v3Id, 'name': 'Cold Coffee', 'price': 60.0, 'category': 'Beverages', 'description': 'Chilled coffee with ice cream', 'isAvailable': true, 'rating': 4.6, 'estimatedMinutes': 7, 'stockCount': 30},
      {'vendorId': v3Id, 'name': 'Masala Chai', 'price': 20.0, 'category': 'Beverages', 'description': 'Spiced Indian tea', 'isAvailable': true, 'rating': 4.5, 'estimatedMinutes': 5, 'stockCount': 50},
      {'vendorId': v3Id, 'name': 'Fresh Lime Soda', 'price': 35.0, 'category': 'Beverages', 'description': 'Refreshing lime soda sweet or salted', 'isAvailable': true, 'rating': 4.4, 'estimatedMinutes': 5, 'stockCount': 40},
      {'vendorId': v3Id, 'name': 'Grilled Sandwich', 'price': 65.0, 'category': 'Sandwiches', 'description': 'Cheese and veggie toasted sandwich', 'isAvailable': true, 'rating': 4.3, 'estimatedMinutes': 12, 'stockCount': 20},
      {'vendorId': v3Id, 'name': 'Paneer Sandwich', 'price': 75.0, 'category': 'Sandwiches', 'description': 'Spiced paneer and veggies in grilled bread', 'isAvailable': true, 'rating': 4.5, 'estimatedMinutes': 15, 'stockCount': 15},
    ];

    final batch2 = _db.batch();
    for (final item in menuItems) {
      final ref = _db.collection('menu_items').doc();
      batch2.set(ref, item);
    }
    await batch2.commit();
  }
}
