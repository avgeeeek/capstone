import 'package:cloud_firestore/cloud_firestore.dart';

class VendorModel {
  final String id;
  final String stallName;
  final String ownerId;
  final String upiId;
  final List<String> cuisine;
  final bool isOpen;
  final double rating;
  final String? imageUrl;
  final String location;
  final String phone;
  final String? openingTime;
  final String? closingTime;
  final bool isActive;

  VendorModel({
    required this.id,
    required this.stallName,
    required this.ownerId,
    required this.upiId,
    required this.cuisine,
    required this.isOpen,
    required this.rating,
    this.imageUrl,
    required this.location,
    required this.phone,
    this.openingTime,
    this.closingTime,
    this.isActive = true,
  });

  factory VendorModel.fromMap(Map<String, dynamic> map, String id) {
    return VendorModel(
      id: id,
      stallName: map['stallName'] ?? '',
      ownerId: map['ownerId'] ?? '',
      upiId: map['upiId'] ?? '',
      cuisine: List<String>.from(map['cuisine'] ?? []),
      isOpen: map['isOpen'] ?? false,
      rating: (map['rating'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'],
      location: map['location'] ?? '',
      phone: map['phone'] ?? '',
      openingTime: map['openingTime'],
      closingTime: map['closingTime'],
      isActive: map['isActive'] ?? true,
    );
  }

  factory VendorModel.fromSnapshot(DocumentSnapshot doc) {
    return VendorModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'stallName': stallName,
      'ownerId': ownerId,
      'upiId': upiId,
      'cuisine': cuisine,
      'isOpen': isOpen,
      'rating': rating,
      'imageUrl': imageUrl,
      'location': location,
      'phone': phone,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'isActive': isActive,
    };
  }

  VendorModel copyWith({
    String? stallName,
    String? upiId,
    List<String>? cuisine,
    bool? isOpen,
    double? rating,
    String? imageUrl,
    String? location,
    String? phone,
    String? openingTime,
    String? closingTime,
    bool? isActive,
  }) {
    return VendorModel(
      id: id,
      stallName: stallName ?? this.stallName,
      ownerId: ownerId,
      upiId: upiId ?? this.upiId,
      cuisine: cuisine ?? this.cuisine,
      isOpen: isOpen ?? this.isOpen,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      isActive: isActive ?? this.isActive,
    );
  }

  String get cuisineString => cuisine.join(', ');
}
