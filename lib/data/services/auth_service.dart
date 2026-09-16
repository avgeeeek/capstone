import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../core/constants/api_constants.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
    required String collegeId,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    
    // Auto-approve if college email, else false
    final isApproved = email.toLowerCase().endsWith(ApiConstants.collegeEmailDomain);

    final user = UserModel(
      id: uid,
      name: name,
      email: email,
      phone: phone,
      role: role,
      collegeId: collegeId,
      isApproved: isApproved,
      createdAt: DateTime.now(),
    );
    await _db
        .collection(ApiConstants.usersCollection)
        .doc(uid)
        .set(user.toMap());
    return user;
  }

  Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    final doc = await _db
        .collection(ApiConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) throw Exception('User profile not found');
    return UserModel.fromSnapshot(doc);
  }

  Future<UserModel> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleUser.authentication.idToken,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    final User? user = userCredential.user;
    if (user == null) throw Exception('Failed to sign in with Google');

    final email = (user.email ?? '').trim().toLowerCase();

    // 1. Check direct doc by UID
    final doc = await _db.collection(ApiConstants.usersCollection).doc(user.uid).get();
    if (doc.exists) {
      return UserModel.fromSnapshot(doc);
    }

    // 2. Check if an existing profile exists with this email (e.g. created by admin as vendor)
    if (email.isNotEmpty) {
      final queryByEmail = await _db
          .collection(ApiConstants.usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (queryByEmail.docs.isNotEmpty) {
        final existingDoc = queryByEmail.docs.first;
        final existingData = existingDoc.data();
        final oldId = existingDoc.id;

        final migratedUser = UserModel(
          id: user.uid,
          name: existingData['name'] ?? user.displayName ?? 'User',
          email: email,
          phone: existingData['phone'] ?? user.phoneNumber ?? '',
          role: existingData['role'] ?? 'student',
          collegeId: existingData['collegeId'] ?? '',
          fcmToken: existingData['fcmToken'],
          photoUrl: existingData['photoUrl'] ?? user.photoURL,
          isApproved: existingData['isApproved'] ?? false,
          isRejected: existingData['isRejected'] ?? false,
          createdAt: (existingData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );

        // Save under user.uid
        await _db.collection(ApiConstants.usersCollection).doc(user.uid).set(migratedUser.toMap());

        // If vendor, update ownerId in vendors collection
        if (migratedUser.isVendor) {
          final vendorSnap = await _db
              .collection(ApiConstants.vendorsCollection)
              .where('ownerId', isEqualTo: oldId)
              .get();
          for (final vDoc in vendorSnap.docs) {
            await _db.collection(ApiConstants.vendorsCollection).doc(vDoc.id).update({
              'ownerId': user.uid,
            });
          }

          final vendorDirect = await _db.collection(ApiConstants.vendorsCollection).doc(oldId).get();
          if (vendorDirect.exists && !vendorSnap.docs.any((d) => d.id == oldId)) {
            final vData = vendorDirect.data()!;
            vData['ownerId'] = user.uid;
            vData['id'] = user.uid;
            await _db.collection(ApiConstants.vendorsCollection).doc(user.uid).set(vData);
            await _db.collection(ApiConstants.vendorsCollection).doc(oldId).delete();
          }
        }

        if (oldId != user.uid) {
          await _db.collection(ApiConstants.usersCollection).doc(oldId).delete();
        }

        return migratedUser;
      }
    }

    // 3. New user registration
    final isApproved = email.endsWith(ApiConstants.collegeEmailDomain);
    final newUser = UserModel(
      id: user.uid,
      name: user.displayName ?? 'Student',
      email: email,
      phone: user.phoneNumber ?? '',
      role: 'student',
      collegeId: '',
      isApproved: isApproved,
      isRejected: false,
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
    );
    await _db.collection(ApiConstants.usersCollection).doc(user.uid).set(newUser.toMap());
    return newUser;
  }

  Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db
        .collection(ApiConstants.usersCollection)
        .doc(user.uid)
        .get();
    if (doc.exists) {
      return UserModel.fromSnapshot(doc);
    }

    final email = (user.email ?? '').trim().toLowerCase();
    if (email.isNotEmpty) {
      final q = await _db
          .collection(ApiConstants.usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (q.docs.isNotEmpty) {
        final existingDoc = q.docs.first;
        final existingData = existingDoc.data();
        final userModel = UserModel.fromMap(existingData, user.uid);
        await _db.collection(ApiConstants.usersCollection).doc(user.uid).set(userModel.toMap());
        return userModel;
      }
    }
    return null;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
    } catch (_) {
      // User may not have signed in with Google
    }
    await _auth.signOut();
  }

  Future<void> updateFcmToken(String uid, String token) async {
    await _db
        .collection(ApiConstants.usersCollection)
        .doc(uid)
        .update({'fcmToken': token});
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db
        .collection(ApiConstants.usersCollection)
        .doc(uid)
        .update(data);
  }
}
