import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vendor_model.dart';
import '../services/firestore_service.dart';
import '../../core/constants/api_constants.dart';

class VendorRepository {
  final FirestoreService _firestoreService;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  VendorRepository(this._firestoreService);

  Stream<List<VendorModel>> getOpenVendors() {
    return _db
        .collection(ApiConstants.vendorsCollection)
        .where('isOpen', isEqualTo: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => VendorModel.fromSnapshot(doc)).toList());
  }

  Stream<List<VendorModel>> getAllVendors() {
    return _db
        .collection(ApiConstants.vendorsCollection)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => VendorModel.fromSnapshot(doc)).toList());
  }

  Future<VendorModel?> getVendorById(String vendorId) async {
    final doc = await _db
        .collection(ApiConstants.vendorsCollection)
        .doc(vendorId)
        .get();
    if (!doc.exists) return null;
    return VendorModel.fromSnapshot(doc);
  }

  Future<VendorModel?> getVendorByOwnerId(String ownerId) async {
    final snap = await _db
        .collection(ApiConstants.vendorsCollection)
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return VendorModel.fromSnapshot(snap.docs.first);
  }

  Stream<VendorModel?> vendorStream(String vendorId) {
    return _db
        .collection(ApiConstants.vendorsCollection)
        .doc(vendorId)
        .snapshots()
        .map((doc) => doc.exists ? VendorModel.fromSnapshot(doc) : null);
  }

  Future<String> createVendor(VendorModel vendor) async {
    final ref = _db.collection(ApiConstants.vendorsCollection).doc(vendor.id);
    await ref.set(vendor.toMap());
    return vendor.id;
  }

  Future<void> updateVendor(String vendorId, Map<String, dynamic> data) async {
    await _db
        .collection(ApiConstants.vendorsCollection)
        .doc(vendorId)
        .update(data);
  }

  Future<void> toggleStallOpen(String vendorId, bool isOpen) async {
    await _db
        .collection(ApiConstants.vendorsCollection)
        .doc(vendorId)
        .update({'isOpen': isOpen});
  }
}
