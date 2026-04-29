// Authentication helper wrapping Firebase auth and user profile persistence
// in Firestore. Provides helpful error mapping for UI-friendly messages.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthResult {
  const AuthResult({required this.success, this.error, this.role});

  final bool success;
  final String? error;
  final String? role;
}

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  String _mapAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'That email is already in use.';
      case 'invalid-email':
        return 'That email address is invalid.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is disabled in Firebase.';
      case 'weak-password':
        return 'Password is too weak (min 6 characters).';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      default:
        final detail = (error.message == null || error.message!.isEmpty)
            ? ''
            : ' ${error.message}';
        return 'Authentication failed (${error.code}).$detail';
    }
  }

  Future<String?> registerGeneralUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        return 'Unable to create account. Please try again.';
      }

      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'role': 'user',
        'created_at': FieldValue.serverTimestamp(),
      });
      return null;
    } on FirebaseAuthException catch (error) {
      print('AUTH ERROR: $error');
      return _mapAuthError(error);
    } catch (error) {
      print('AUTH ERROR: $error');
      return error.toString();
    }
  }

  Future<String?> registerProfessionalUser({
    required String name,
    required String email,
    required String password,
    required String licenseNumber,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        return 'Unable to create account. Please try again.';
      }

      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'role': 'psychiatrist',
        'license_number': licenseNumber,
        'is_verified': false,
        'created_at': FieldValue.serverTimestamp(),
      });
      return null;
    } on FirebaseAuthException catch (error) {
      print('AUTH ERROR: $error');
      return _mapAuthError(error);
    } catch (error) {
      print('AUTH ERROR: $error');
      return error.toString();
    }
  }

  Future<AuthResult> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        return const AuthResult(
          success: false,
          error: 'Login failed. Please try again.',
        );
      }
      final snapshot = await _firestore.collection('users').doc(uid).get();
      final data = snapshot.data();
      final role = data?['role'] as String?;
      if (role == null) {
        return const AuthResult(
          success: false,
          error: 'No role assigned to this account.',
        );
      }
      return AuthResult(success: true, role: role);
    } on FirebaseAuthException catch (error) {
      return AuthResult(
        success: false,
        error: _mapAuthError(error),
      );
    } catch (error) {
      return const AuthResult(
        success: false,
        error: 'Login failed. Please try again.',
      );
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    return snapshot.data();
  }

  Future<String?> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();
    return data?['role'] as String?;
  }
}
