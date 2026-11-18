import 'package:flutter/foundation.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/review_repository.dart';
import '../../core/utils/helpers.dart';

enum ReviewState { idle, loading, success, error }

class ReviewProvider extends ChangeNotifier {
  final ReviewRepository _reviewRepository;

  ReviewState _state = ReviewState.idle;
  String? _errorMessage;
  List<ReviewModel> _vendorReviews = [];
  bool _hasReviewed = false;

  ReviewProvider(this._reviewRepository);

  ReviewState get state => _state;
  String? get errorMessage => _errorMessage;
  List<ReviewModel> get vendorReviews => _vendorReviews;
  bool get hasReviewed => _hasReviewed;
  bool get isLoading => _state == ReviewState.loading;

  Future<bool> submitReview({
    required String orderId,
    required String studentId,
    required String vendorId,
    required double rating,
    String? comment,
    String? studentName,
  }) async {
    _setState(ReviewState.loading);
    try {
      final review = ReviewModel(
        id: Helpers.generateId(),
        orderId: orderId,
        studentId: studentId,
        vendorId: vendorId,
        rating: rating,
        comment: comment,
        studentName: studentName,
        createdAt: DateTime.now(),
      );

      await _reviewRepository.submitReview(review);
      _hasReviewed = true;
      _setState(ReviewState.success);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ReviewState.error);
      return false;
    }
  }

  Future<void> checkIfReviewed(String orderId, String studentId) async {
    _hasReviewed = await _reviewRepository.hasReviewedOrder(orderId, studentId);
    notifyListeners();
  }

  Stream<List<ReviewModel>> getVendorReviewsStream(String vendorId) {
    return _reviewRepository.getReviewsForVendor(vendorId);
  }

  Future<void> loadVendorReviews(String vendorId) async {
    try {
      _vendorReviews = await _reviewRepository.getReviewsForVendorOnce(vendorId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _setState(ReviewState state) {
    _state = state;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
