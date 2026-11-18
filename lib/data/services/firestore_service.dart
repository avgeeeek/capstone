import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirebaseFirestore get db => _db;

  // --- Generic CRUD ---

  Future<String> addDocument(String collection, Map<String, dynamic> data) async {
    final ref = await _db.collection(collection).add(data);
    return ref.id;
  }

  Future<void> setDocument(String collection, String docId, Map<String, dynamic> data,
      {bool merge = false}) async {
    await _db.collection(collection).doc(docId).set(data, SetOptions(merge: merge));
  }

  Future<void> updateDocument(
      String collection, String docId, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(docId).update(data);
  }

  Future<void> deleteDocument(String collection, String docId) async {
    await _db.collection(collection).doc(docId).delete();
  }

  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    return await _db.collection(collection).doc(docId).get();
  }

  Stream<DocumentSnapshot> documentStream(String collection, String docId) {
    return _db.collection(collection).doc(docId).snapshots();
  }

  Stream<QuerySnapshot> collectionStream(
    String collection, {
    List<List<dynamic>>? whereConditions,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query query = _db.collection(collection);
    if (whereConditions != null) {
      for (final cond in whereConditions) {
        query = query.where(cond[0] as String, isEqualTo: cond[1]);
      }
    }
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }
    return query.snapshots();
  }

  Future<QuerySnapshot> getCollection(
    String collection, {
    String? whereField,
    dynamic whereValue,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    Query query = _db.collection(collection);
    if (whereField != null) {
      query = query.where(whereField, isEqualTo: whereValue);
    }
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }
    return await query.get();
  }

  // Transaction support
  Future<void> runTransaction(Function(Transaction) handler) async {
    await _db.runTransaction(handler as Future<dynamic> Function(Transaction));
  }
}
