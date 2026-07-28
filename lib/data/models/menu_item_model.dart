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
  });

  factory MenuItemModel.fromMap(Map<String, dynamic> map, String id) {
    return MenuItemModel(
      id: id,
      vendorId: map['vendorId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      category: map['category'] ?? 'Other',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      isAvailable: map['isAvailable'] ?? true,
      rating: (map['rating'] ?? 0.0).toDouble(),
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
    );
  }
}
