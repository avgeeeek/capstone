import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItemModel {
  final String id;
  final String vendorId;
  final String name;
  final double price;
  final String category;
  final String description;
  final String? imageUrl;
  final bool isAvailable;
  final double rating;
  /// null = unlimited (no stock tracking), ≥ 0 = tracked quantity
  final int? stockCount;
  /// Estimated preparation time in minutes (null = not set)
  final int? estimatedMinutes;

  MenuItemModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    this.imageUrl,
    required this.isAvailable,
    required this.rating,
    this.stockCount,
    this.estimatedMinutes,
  });

  /// True when item is out of stock (stock is 0 or less)
  bool get isOutOfStock => (stockCount ?? 0) <= 0;
  /// True when stock is tracked
  bool get hasStockTracking => true;

  factory MenuItemModel.fromMap(Map<String, dynamic> map, String id) {
    final parsedStock = (map['stockCount'] as num?)?.toInt() ?? 20;
    final bool availableInDb = map['isAvailable'] ?? true;
    return MenuItemModel(
      id: id,
      vendorId: map['vendorId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      category: map['category'] ?? 'Other',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      isAvailable: availableInDb && parsedStock > 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      stockCount: parsedStock,
      estimatedMinutes: (map['estimatedMinutes'] as num?)?.toInt() ?? 15,
    );
  }

  factory MenuItemModel.fromSnapshot(DocumentSnapshot doc) {
    return MenuItemModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'vendorId': vendorId,
      'name': name,
      'price': price,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'rating': rating,
      'stockCount': stockCount,
      'estimatedMinutes': estimatedMinutes,
    };
  }

  MenuItemModel copyWith({
    String? name,
    double? price,
    String? category,
    String? description,
    String? imageUrl,
    bool? isAvailable,
    double? rating,
    Object? stockCount = _sentinel,
    Object? estimatedMinutes = _sentinel,
  }) {
    return MenuItemModel(
      id: id,
      vendorId: vendorId,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      stockCount: stockCount == _sentinel ? this.stockCount : stockCount as int?,
      estimatedMinutes: estimatedMinutes == _sentinel ? this.estimatedMinutes : estimatedMinutes as int?,
    );
  }
}

// Sentinel to distinguish "not passed" from null in copyWith
const Object _sentinel = Object();
