import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // "student" | "vendor" | "admin"
  final String collegeId;
  final String? fcmToken;
  final String? photoUrl;
  final bool isApproved;
  final bool isRejected;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.collegeId,
    this.fcmToken,
    this.photoUrl,
    this.isApproved = false,
    this.isRejected = false,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'student',
      collegeId: map['collegeId'] ?? '',
      fcmToken: map['fcmToken'],
      photoUrl: map['photoUrl'],
      isApproved: map['isApproved'] ?? false,
      isRejected: map['isRejected'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory UserModel.fromSnapshot(DocumentSnapshot doc) {
    return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'collegeId': collegeId,
      'fcmToken': fcmToken,
      'photoUrl': photoUrl,
      'isApproved': isApproved,
      'isRejected': isRejected,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? collegeId,
    String? fcmToken,
    String? photoUrl,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      collegeId: collegeId ?? this.collegeId,
      fcmToken: fcmToken ?? this.fcmToken,
      photoUrl: photoUrl ?? this.photoUrl,
      isApproved: isApproved,
      createdAt: createdAt,
    );
  }

  bool get isStudent => role == 'student';
  bool get isVendor => role == 'vendor';
  bool get isAdmin => role == 'admin';

  /// True when student is waiting (not yet approved and not rejected)
  bool get isPendingApproval => !isApproved && !isRejected;
}
