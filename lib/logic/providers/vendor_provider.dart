import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/vendor_model.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/vendor_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/services/fcm_service.dart';
import '../../core/constants/api_constants.dart';

enum VendorState { idle, loading, success, error }

class VendorProvider extends ChangeNotifier {
  final VendorRepository _vendorRepository;
  final OrderRepository _orderRepository;
  final FcmService _fcmService;

  VendorModel? _vendor;
  VendorState _state = VendorState.idle;
  String? _errorMessage;

  VendorProvider(this._vendorRepository, this._orderRepository, this._fcmService);

  VendorModel? get vendor => _vendor;
  VendorState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == VendorState.loading;
  bool get isOpen => _vendor?.isOpen ?? false;

  Future<void> loadVendorByOwnerId(String ownerId) async {
    _setState(VendorState.loading);
    try {
      _vendor = await _vendorRepository.getVendorByOwnerId(ownerId);
      _setState(VendorState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(VendorState.error);
    }
  }

  Stream<VendorModel?> vendorStream(String vendorId) =>
      _vendorRepository.vendorStream(vendorId);

  Stream<List<OrderModel>> vendorOrdersStream(String vendorId) =>
      _orderRepository.vendorOrdersStream(vendorId);

  Future<bool> toggleStallOpen(bool isOpen) async {
    if (_vendor == null) return false;
    try {
      await _vendorRepository.toggleStallOpen(_vendor!.id, isOpen);
      _vendor = _vendor!.copyWith(isOpen: isOpen);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> acceptOrder(
    OrderModel order,
    int estimatedMinutes,
    String studentId,
  ) async {
    try {
      final estimatedReadyAt =
          DateTime.now().add(Duration(minutes: estimatedMinutes));
      await _orderRepository.acceptOrder(
          order.id, estimatedMinutes, estimatedReadyAt);

      // Notify student
      await _fcmService.notifyOrderAccepted(
        studentId: studentId,
        orderId: order.id,
        stallName: _vendor?.stallName ?? 'Your stall',
        estimatedMinutes: estimatedMinutes,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> markOrderReady(OrderModel order, String studentId) async {
    try {
      await _orderRepository.markReady(order.id);

      // Notify student
      await _fcmService.notifyOrderReady(
        studentId: studentId,
        orderId: order.id,
        stallName: _vendor?.stallName ?? 'Your stall',
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> confirmPickup(String orderId) async {
    try {
      await _orderRepository.confirmPickup(orderId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectOrder(
    OrderModel order,
    String studentId, {
    String? reason,
  }) async {
    try {
      await _orderRepository.rejectOrder(order.id, reason: reason);

      await _fcmService.notifyOrderRejected(
        studentId: studentId,
        orderId: order.id,
        stallName: _vendor?.stallName ?? 'Your stall',
        reason: reason,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<OrderModel?> getOrderByQrData(String qrData) async {
    // Extract orderId from qrData: campuseats://order/{orderId}
    String orderId = qrData;
    if (qrData.startsWith('campuseats://order/')) {
      orderId = qrData.replaceFirst('campuseats://order/', '');
    }
    return await _orderRepository.getOrderById(orderId);
  }

  void _setState(VendorState state) {
    _state = state;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
