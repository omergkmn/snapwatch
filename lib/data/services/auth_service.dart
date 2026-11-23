import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  Future<User> signInAsGuest() async {
    final user = _auth.currentUser;
    if (user != null) return user;

    final credential = await _auth.signInAnonymously();
    return credential.user!;
  }

  /// Deletes the guest account. If Firebase refuses (for example offline),
  /// the user is at least signed out so the next start creates a new one.
  Future<void> deleteGuest() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException {
      await _auth.signOut();
    }
  }
}
