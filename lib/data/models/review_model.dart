import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String orderId;
  final String studentId;
  final String vendorId;
  final double rating;
  final String? comment;
  final String? studentName;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.orderId,
    required this.studentId,
    required this.vendorId,
    required this.rating,
    this.comment,
    this.studentName,
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
      studentName: map['studentName'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory ReviewModel.fromSnapshot(DocumentSnapshot doc) {
    return ReviewModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'studentId': studentId,
      'vendorId': vendorId,
      'rating': rating,
      'comment': comment,
      'studentName': studentName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ReviewModel copyWith({
    double? rating,
    String? comment,
    String? studentName,
  }) {
    return ReviewModel(
      id: id,
      orderId: orderId,
      studentId: studentId,
      vendorId: vendorId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      studentName: studentName ?? this.studentName,
      createdAt: createdAt,
    );
  }
}
