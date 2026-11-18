import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_item_model.dart';

class OrderModel {
  final String id;
  final String studentId;
  final String vendorId;
  final List<OrderItemModel> items;
  final double totalAmount;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final int? estimatedMinutes;
  final DateTime? estimatedReadyAt;
  final DateTime? acceptedAt;
  final DateTime? readyAt;
  final DateTime? pickedUpAt;
  final DateTime? cancelledAt;
  final DateTime placedAt;
  final String qrCodeData;
  final String? rejectionReason;
  final String? cancellationReason;
  // Joined fields (not stored in Firestore, fetched separately)
  String? studentName;
  String? vendorName;
  String? vendorStallName;

  OrderModel({
    required this.id,
    required this.studentId,
    required this.vendorId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    this.estimatedMinutes,
    this.estimatedReadyAt,
    this.acceptedAt,
    this.readyAt,
    this.pickedUpAt,
    this.cancelledAt,
    required this.placedAt,
    required this.qrCodeData,
    this.rejectionReason,
    this.cancellationReason,
    this.studentName,
    this.vendorName,
    this.vendorStallName,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      studentId: map['studentId'] ?? '',
      vendorId: map['vendorId'] ?? '',
      items: (map['items'] as List<dynamic>? ?? [])
          .map((i) => OrderItemModel.fromMap(i as Map<String, dynamic>))
          .toList(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      paymentStatus: map['paymentStatus'] ?? 'pending',
      paymentMethod: map['paymentMethod'] ?? 'cash',
      estimatedMinutes: map['estimatedMinutes'],
      estimatedReadyAt: (map['estimatedReadyAt'] as Timestamp?)?.toDate(),
      acceptedAt: (map['acceptedAt'] as Timestamp?)?.toDate(),
      readyAt: (map['readyAt'] as Timestamp?)?.toDate(),
      pickedUpAt: (map['pickedUpAt'] as Timestamp?)?.toDate(),
      cancelledAt: (map['cancelledAt'] as Timestamp?)?.toDate(),
      placedAt: (map['placedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      qrCodeData: map['qrCodeData'] ?? '',
      rejectionReason: map['rejectionReason'],
      cancellationReason: map['cancellationReason'],
    );
  }

  factory OrderModel.fromSnapshot(DocumentSnapshot doc) {
    return OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'vendorId': vendorId,
      'items': items.map((i) => i.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'estimatedMinutes': estimatedMinutes,
      'estimatedReadyAt':
          estimatedReadyAt != null ? Timestamp.fromDate(estimatedReadyAt!) : null,
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'readyAt': readyAt != null ? Timestamp.fromDate(readyAt!) : null,
      'pickedUpAt': pickedUpAt != null ? Timestamp.fromDate(pickedUpAt!) : null,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'placedAt': Timestamp.fromDate(placedAt),
      'qrCodeData': qrCodeData,
      'rejectionReason': rejectionReason,
      'cancellationReason': cancellationReason,
    };
  }

  OrderModel copyWith({
    String? status,
    String? paymentStatus,
    int? estimatedMinutes,
    DateTime? estimatedReadyAt,
    DateTime? acceptedAt,
    DateTime? readyAt,
    DateTime? pickedUpAt,
    DateTime? cancelledAt,
    String? rejectionReason,
    String? cancellationReason,
    String? qrCodeData,
  }) {
    return OrderModel(
      id: id,
      studentId: studentId,
      vendorId: vendorId,
      items: items,
      totalAmount: totalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      estimatedReadyAt: estimatedReadyAt ?? this.estimatedReadyAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      readyAt: readyAt ?? this.readyAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      placedAt: placedAt,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      studentName: studentName,
      vendorName: vendorName,
      vendorStallName: vendorStallName,
    );
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isPreparing => status == 'preparing';
  bool get isReady => status == 'ready';
  bool get isPickedUp => status == 'picked_up';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';
  bool get isActive => !isPickedUp && !isRejected && !isCancelled;
  bool get isGpay => paymentMethod == 'gpay';
  bool get isCash => paymentMethod == 'cash';

  Duration? get remainingTime {
    if (estimatedReadyAt == null) return null;
    return estimatedReadyAt!.difference(DateTime.now());
  }
}
