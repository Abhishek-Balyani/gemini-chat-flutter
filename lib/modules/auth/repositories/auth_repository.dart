import '../../../core/services/storage_service.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';

class AuthRepository {
  final BaseAuthService _authService;
  final StorageService _storageService;

  AuthRepository(this._authService, this._storageService);

  UserModel? getCachedUser() {
    return _authService.currentUser;
  }

  Future<UserModel> signInAnonymously() async {
    final user = await _authService.signInAnonymously();
    await _cacheUser(user);
    return user;
  }

  Future<UserModel> signInWithEmailPassword(String email, String password) async {
    final user = await _authService.signInWithEmailPassword(email, password);
    await _cacheUser(user);
    return user;
  }

  Future<UserModel> signUpWithEmailPassword(String email, String password, String displayName) async {
    final user = await _authService.signUpWithEmailPassword(email, password, displayName);
    await _cacheUser(user);
    return user;
  }

  Future<UserModel?> signInWithGoogle() async {
    final user = await _authService.signInWithGoogle();
    if (user != null) {
      await _cacheUser(user);
    }
    return user;
  }

  Future<UserModel?> signInWithApple() async {
    final user = await _authService.signInWithApple();
    if (user != null) {
      await _cacheUser(user);
    }
    return user;
  }

  Future<UserModel?> signInWithFacebook() async {
    final user = await _authService.signInWithFacebook();
    if (user != null) {
      await _cacheUser(user);
    }
    return user;
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> _cacheUser(UserModel user) async {
    await _storageService.saveRawConversations([]);
  }
}
