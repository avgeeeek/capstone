import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String orderId;
  final String studentId;
  final String vendorId;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.orderId,
    required this.studentId,
    required this.vendorId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      id: id,
      orderId: map['orderId'] ?? '',
      studentId: map['studentId'] ?? '',
      vendorId: map['vendorId'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'studentId': studentId,
      'vendorId': vendorId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
