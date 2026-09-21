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

    final doc = await _db.collection(ApiConstants.usersCollection).doc(user.uid).get();

    if (doc.exists) {
      return UserModel.fromSnapshot(doc);
    } else {
      final email = user.email ?? '';
      final isApproved = email.toLowerCase().endsWith(ApiConstants.collegeEmailDomain);

      // Create new user record for first-time Google sign-in
      final newUser = UserModel(
        id: user.uid,
        name: user.displayName ?? 'Student',
        email: email,
        phone: user.phoneNumber ?? '',
        role: 'student', // Default role
        collegeId: '',
        isApproved: isApproved,
        createdAt: DateTime.now(),
      );
      await _db.collection(ApiConstants.usersCollection).doc(user.uid).set(newUser.toMap());
      return newUser;
    }
  }


  Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db
        .collection(ApiConstants.usersCollection)
        .doc(user.uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromSnapshot(doc);
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
