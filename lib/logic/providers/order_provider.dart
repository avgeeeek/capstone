import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/order_model.dart';
import '../../data/models/order_item_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/services/fcm_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/helpers.dart';

enum OrderState { idle, loading, success, error }

class OrderProvider extends ChangeNotifier {
  final OrderRepository _orderRepository;
  final FcmService _fcmService;

  List<OrderModel> _studentOrders = [];
  OrderModel? _currentOrder;
  OrderState _state = OrderState.idle;
  String? _errorMessage;
  String? _lastPlacedOrderId;

  OrderProvider(this._orderRepository, this._fcmService);

  List<OrderModel> get studentOrders => _studentOrders;
  List<OrderModel> get activeOrders =>
      _studentOrders.where((o) => o.isActive).toList();
  List<OrderModel> get completedOrders =>
      _studentOrders.where((o) => !o.isActive).toList();
  OrderModel? get currentOrder => _currentOrder;
  OrderState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == OrderState.loading;
  String? get lastPlacedOrderId => _lastPlacedOrderId;

  Stream<OrderModel?> orderStream(String orderId) =>
      _orderRepository.orderStream(orderId);

  Stream<List<OrderModel>> studentOrdersStream(String studentId) =>
      _orderRepository.studentOrdersStream(studentId);

  Future<String?> placeOrder({
    required String studentId,
    required String vendorId,
    required List<OrderItemModel> items,
    required double totalAmount,
    required String paymentMethod,
    required String paymentStatus,
    required String vendorUserId,
    required String studentName,
  }) async {
    _setState(OrderState.loading);
    try {
      final orderId = Helpers.generateId();
      final qrData = Helpers.generateQrData(orderId);

      final order = OrderModel(
        id: orderId,
        studentId: studentId,
        vendorId: vendorId,
        items: items,
        totalAmount: totalAmount,
        status: ApiConstants.statusPending,
        paymentStatus: paymentStatus,
        paymentMethod: paymentMethod,
        placedAt: DateTime.now(),
        qrCodeData: qrData,
      );

      await _orderRepository.placeOrder(order);
      _lastPlacedOrderId = orderId;

      // Notify vendor
      await _fcmService.notifyOrderPlaced(
        vendorUserId: vendorUserId,
        orderId: orderId,
        studentName: studentName,
      );

      _setState(OrderState.success);
      return orderId;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(OrderState.error);
      return null;
    }
  }

  Future<bool> updatePaymentStatus(String orderId, String paymentStatus) async {
    try {
      await _orderRepository.updatePaymentStatus(orderId, paymentStatus);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    try {
      await _orderRepository.cancelOrder(orderId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    return await _orderRepository.getOrderById(orderId);
  }

  void _setState(OrderState state) {
    _state = state;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
