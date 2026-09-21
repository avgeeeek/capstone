import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';
import '../../core/constants/api_constants.dart';

class ReviewRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> submitReview(ReviewModel review) async {
    // Save the review
    await _db
        .collection(ApiConstants.reviewsCollection)
        .doc(review.id)
        .set(review.toMap());

    // Update vendor average rating
    await _updateVendorRating(review.vendorId);
  }

  Future<double> _updateVendorRating(String vendorId) async {
    final snap = await _db
        .collection(ApiConstants.reviewsCollection)
        .where('vendorId', isEqualTo: vendorId)
        .get();

    if (snap.docs.isEmpty) return 0.0;

    final totalRating = snap.docs.fold<double>(
      0.0,
      (acc, doc) => acc + ((doc.data()['rating'] ?? 0.0) as num).toDouble(),
    );
    final avgRating = totalRating / snap.docs.length;

    await _db
        .collection(ApiConstants.vendorsCollection)
        .doc(vendorId)
        .update({'rating': double.parse(avgRating.toStringAsFixed(1))});

    return avgRating;
  }

  Future<double> getVendorAverageRating(String vendorId) =>
      _updateVendorRating(vendorId);

  Stream<List<ReviewModel>> getReviewsForVendor(String vendorId) {
    return _db
        .collection(ApiConstants.reviewsCollection)
        .where('vendorId', isEqualTo: vendorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => ReviewModel.fromSnapshot(doc)).toList());
  }

  Future<List<ReviewModel>> getReviewsForVendorOnce(String vendorId) async {
    final snap = await _db
        .collection(ApiConstants.reviewsCollection)
        .where('vendorId', isEqualTo: vendorId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((doc) => ReviewModel.fromSnapshot(doc)).toList();
  }

  Future<bool> hasReviewedOrder(String orderId, String studentId) async {
    final snap = await _db
        .collection(ApiConstants.reviewsCollection)
        .where('orderId', isEqualTo: orderId)
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<int> getReviewCountForVendor(String vendorId) async {
    final snap = await _db
        .collection(ApiConstants.reviewsCollection)
        .where('vendorId', isEqualTo: vendorId)
        .count()
        .get();
    return snap.count ?? 0;
  }
}
