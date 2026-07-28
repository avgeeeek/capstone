import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import '../../core/constants/api_constants.dart';

class NotificationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<NotificationModel>> notificationsStream(String userId) {
    return _db
        .collection(ApiConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => NotificationModel.fromSnapshot(doc))
            .toList());
  }

  Future<void> markAsRead(String notifId) async {
    await _db
        .collection(ApiConstants.notificationsCollection)
        .doc(notifId)
        .update({'isRead': true});
  }

  Future<void> markAllAsRead(String userId) async {
    final snap = await _db
        .collection(ApiConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<int> getUnreadCount(String userId) async {
    final snap = await _db
        .collection(ApiConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .count()
        .get();
    return snap.count ?? 0;
  }

  Stream<int> unreadCountStream(String userId) {
    return _db
        .collection(ApiConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }
}
