class OrderItemModel {
  final String itemId;
  final String name;
  final int quantity;
  final double price;
  final double total;

  OrderItemModel({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      itemId: map['itemId'] ?? '',
      name: map['name'] ?? '',
      quantity: (map['quantity'] ?? 1).toInt(),
      price: (map['price'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }
}
