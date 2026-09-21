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

}
