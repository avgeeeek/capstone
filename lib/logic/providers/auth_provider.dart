import 'package:flutter/foundation.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/fcm_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final FcmService _fcmService;

  UserModel? _currentUser;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;

  AuthProvider(this._authRepository, this._fcmService);

  UserModel? get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isStudent => _currentUser?.isStudent ?? false;
  bool get isVendor => _currentUser?.isVendor ?? false;
  String get userId => _currentUser?.id ?? '';
  String get userName => _currentUser?.name ?? '';

  Future<void> init() async {
    _setStatus(AuthStatus.loading);
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        _setStatus(AuthStatus.authenticated);
        await _refreshFcmToken();
      } else {
        _setStatus(AuthStatus.unauthenticated);
      }
    } catch (e) {
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
    required String collegeId,
  }) async {
    _setStatus(AuthStatus.loading);
    try {
      final user = await _authRepository.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
        collegeId: collegeId,
      );
      _currentUser = user;
      _setStatus(AuthStatus.authenticated);
      await _refreshFcmToken();
      return true;
    } catch (e) {
      _errorMessage = _parseFirebaseError(e.toString());
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _setStatus(AuthStatus.loading);
    try {
      final user = await _authRepository.login(email: email, password: password);
      _currentUser = user;
      _setStatus(AuthStatus.authenticated);
      await _refreshFcmToken();
      return true;
    } catch (e) {
      _errorMessage = _parseFirebaseError(e.toString());
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _setStatus(AuthStatus.loading);
    try {
      final user = await _authRepository.signInWithGoogle();
      _currentUser = user;
      _setStatus(AuthStatus.authenticated);
      await _refreshFcmToken();
      return true;
    } catch (e) {
      _errorMessage = _parseFirebaseError(e.toString());
      _setStatus(AuthStatus.error);
      return false;
    }
  }


  Future<bool> sendPasswordReset(String email) async {
    try {
      await _authRepository.sendPasswordReset(email);
      return true;
    } catch (e) {
      _errorMessage = _parseFirebaseError(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    _currentUser = null;
    _setStatus(AuthStatus.unauthenticated);
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_currentUser == null) return;
    await _authRepository.updateProfile(_currentUser!.id, data);
    // Refresh
    final updated = await _authRepository.getCurrentUser();
    if (updated != null) {
      _currentUser = updated;
      notifyListeners();
    }
  }

  Future<void> _refreshFcmToken() async {
    if (_currentUser == null) return;
    try {
      final token = await _fcmService.getToken();
      if (token != null) {
        await _authRepository.updateFcmToken(_currentUser!.id, token);
      }
    } catch (_) {}
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  String _parseFirebaseError(String error) {
    if (error.contains('user-not-found')) return 'No account found with this email';
    if (error.contains('wrong-password')) return 'Incorrect password';
    if (error.contains('email-already-in-use')) return 'Email already registered';
    if (error.contains('invalid-email')) return 'Invalid email address';
    if (error.contains('weak-password')) return 'Password is too weak (min 6 chars)';
    if (error.contains('network-request-failed')) return 'Network error. Check your connection.';
    if (error.contains('too-many-requests')) return 'Too many attempts. Try again later.';
    return 'An error occurred. Please try again.';
  }
}
