import 'package:flutter/foundation.dart';
import '../../data/models/menu_item_model.dart';
import '../../data/models/order_item_model.dart';

class CartItem {
  final MenuItemModel menuItem;
  int quantity;

  CartItem({required this.menuItem, this.quantity = 1});

  double get itemTotal => menuItem.price * quantity;

  OrderItemModel toOrderItem() {
    return OrderItemModel(
      itemId: menuItem.id,
      name: menuItem.name,
      quantity: quantity,
      price: menuItem.price,
      total: itemTotal,
    );
  }
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  String? _vendorId;
  String? _vendorName;
  String? _vendorUpiId;

  List<CartItem> get items => List.unmodifiable(_items);
  String? get vendorId => _vendorId;
  String? get vendorName => _vendorName;
  String? get vendorUpiId => _vendorUpiId;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.itemTotal);

  double get total => subtotal; // Can add taxes/delivery fees here

  List<OrderItemModel> get orderItems =>
      _items.map((i) => i.toOrderItem()).toList();

  /// Maximum estimated preparation time among items currently in cart
  int get estimatedPrepMinutes {
    if (_items.isEmpty) return 15;
    int maxMinutes = 15;
    for (final item in _items) {
      final m = item.menuItem.estimatedMinutes ?? 15;
      if (m > maxMinutes) maxMinutes = m;
    }
    return maxMinutes;
  }

  /// Add item — clears cart if from different vendor
  bool addItem(MenuItemModel menuItem, String vendorId, String vendorName,
      String vendorUpiId) {
    // If adding from a different vendor, clear cart first
    if (_vendorId != null && _vendorId != vendorId) {
      return false; // Signal caller to show confirmation dialog
    }

    _vendorId = vendorId;
    _vendorName = vendorName;
    _vendorUpiId = vendorUpiId;

    final existingIndex =
        _items.indexWhere((i) => i.menuItem.id == menuItem.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(menuItem: menuItem));
    }
    notifyListeners();
    return true;
  }

  void forceAddItem(MenuItemModel menuItem, String vendorId, String vendorName,
      String vendorUpiId) {
    clearCart();
    addItem(menuItem, vendorId, vendorName, vendorUpiId);
  }

  void increment(String itemId) {
    final index = _items.indexWhere((i) => i.menuItem.id == itemId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decrement(String itemId) {
    final index = _items.indexWhere((i) => i.menuItem.id == itemId);
    if (index >= 0) {
      if (_items[index].quantity <= 1) {
        _items.removeAt(index);
      } else {
        _items[index].quantity--;
      }
      if (_items.isEmpty) {
        _vendorId = null;
        _vendorName = null;
        _vendorUpiId = null;
      }
      notifyListeners();
    }
  }

  void removeItem(String itemId) {
    _items.removeWhere((i) => i.menuItem.id == itemId);
    if (_items.isEmpty) {
      _vendorId = null;
      _vendorName = null;
      _vendorUpiId = null;
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _vendorId = null;
    _vendorName = null;
    _vendorUpiId = null;
    notifyListeners();
  }

  int getItemQuantity(String itemId) {
    final index = _items.indexWhere((i) => i.menuItem.id == itemId);
    return index >= 0 ? _items[index].quantity : 0;
  }

  bool hasItem(String itemId) => _items.any((i) => i.menuItem.id == itemId);
}
