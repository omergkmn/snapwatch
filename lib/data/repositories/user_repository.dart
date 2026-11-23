import 'package:firebase_auth/firebase_auth.dart';

import '../../core/errors/app_exception.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';

class UserRepository {
  UserRepository(this._storage, this._authService);

  final LocalStorageService _storage;
  final AuthService _authService;

  bool get isOnboardingCompleted => _storage.isOnboardingCompleted;

  UserProfile? get profile => _storage.readUserProfile();

  DateTime? get memberSince => _authService.currentUser?.metadata.creationTime;

  Future<void> completeOnboarding(UserProfile profile) async {
    try {
      await _authService.signInAsGuest();
    } on FirebaseAuthException catch (e) {
      throw AppException(
        e.code == 'network-request-failed'
            ? AppErrorType.network
            : AppErrorType.unknown,
      );
    }
    await _storage.saveUserProfile(profile);
    await _storage.setOnboardingCompleted();
  }

  Future<void> deleteAccount() async {
    await _authService.deleteGuest();
    await _storage.clearAll();
  }
}
