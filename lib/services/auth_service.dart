import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  AuthService() {
    _user = _auth.currentUser;
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      // Verify Firebase Auth is available
      if (_auth.app == null) {
        throw Exception('Firebase Auth not initialized. Please check Firebase configuration.');
      }
      
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign in error: ${e.code} - ${e.message}');
      if (e.code == 'channel-error' || e.code == 'unknown') {
        throw Exception('Firebase Authentication is not enabled. Please enable Email/Password authentication in Firebase Console.');
      }
      rethrow;
    } catch (e) {
      debugPrint('Sign in error: $e');
      if (e.toString().contains('channel-error')) {
        throw Exception('Firebase Authentication is not enabled. Please:\n1. Go to Firebase Console\n2. Enable Authentication\n3. Enable Email/Password sign-in method\n4. Restart the app');
      }
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
