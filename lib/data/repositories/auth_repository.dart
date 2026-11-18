import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
    required String collegeId,
  }) {
    return _authService.registerUser(
      email: email,
      password: password,
      name: name,
      phone: phone,
      role: role,
      collegeId: collegeId,
    );
  }

  Future<UserModel> login({required String email, required String password}) {
    return _authService.loginUser(email: email, password: password);
  }

  Future<UserModel?> getCurrentUser() => _authService.getCurrentUserModel();

  Future<UserModel> signInWithGoogle() {
    return _authService.signInWithGoogle();
  }

  Future<void> sendPasswordReset(String email) =>
      _authService.sendPasswordResetEmail(email);

  Future<void> signOut() => _authService.signOut();

  Stream<dynamic> get authState => _authService.authStateChanges;

  Future<void> updateFcmToken(String uid, String token) =>
      _authService.updateFcmToken(uid, token);

  Future<void> updateProfile(String uid, Map<String, dynamic> data) =>
      _authService.updateUserProfile(uid, data);
}
