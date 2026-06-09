// =============================================================================
// NADDEFLI — firebase_auth_service.dart
// Layer: Flutter — Service (Firebase)
// Purpose: Firebase email/password and Google Sign-In, then syncs user with backend API.
// Connects to: firebase_auth, google_sign_in → backend /api/auth/register|login|google
// =============================================================================

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/constants.dart';
import '../utils/storage_service.dart';
import 'http_service.dart';

/// Firebase Authentication Service
class FirebaseAuthService {
  static final firebase_auth.FirebaseAuth _firebaseAuth = 
      firebase_auth.FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '521552881955-kidel4uek77mk750d4l9aejqbfemtti3.apps.googleusercontent.com',
  );

  /// Sign up with email and password
  /// Creates Firebase user + backend user
  static Future<Map<String, dynamic>> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      // 1. Create Firebase user
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return {'success': false, 'message': 'Failed to create Firebase user'};
      }

      // 2. Register in backend API
      final response = await HttpService.post(
        ApiEndpoints.register,
        data: {
          'full_name': fullName,
          'email': email,
          'password': password,
          'phone': phone,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data;
        if (data['success'] && data['data'] != null) {
          final token = data['data']['token'];
          final user = data['data']['user'];
          
          // Save to local storage
          await StorageService.saveToken(token);
          await StorageService.saveUserId(user['id'].toString());
          await StorageService.saveUserRole(user['role'].toString());

          return {'success': true, 'data': data['data']};
        }
      }

      // If backend fails, delete Firebase user
      await firebaseUser.delete();
      return {
        'success': false,
        'message': response.data['message'] ?? 'Registration failed'
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'email-already-in-use') {
        message = 'Email already registered';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      } else if (e.code == 'operation-not-allowed') {
        message = 'Email/Password sign-in is not enabled. Please enable it in Firebase Console.';
      } else {
        message = 'Authentication failed (${e.code}): ${e.message}';
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Sign up failed: ${e.toString()}'};
    }
  }

  /// Sign in with email and password
  static Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Authenticate with Firebase
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return {'success': false, 'message': 'Sign in failed'};
      }

      // 2. Login via backend API
      final response = await HttpService.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] && data['data'] != null) {
          final token = data['data']['token'];
          final user = data['data']['user'];

          // Save to local storage
          await StorageService.saveToken(token);
          await StorageService.saveUserId(user['id'].toString());
          await StorageService.saveUserRole(user['role'].toString());

          return {'success': true, 'data': data['data']};
        }
      }

      // If backend fails, sign out from Firebase
      await _firebaseAuth.signOut();
      return {
        'success': false,
        'message': response.data['message'] ?? 'Login failed'
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Invalid email or password';
      } else if (e.code == 'user-disabled') {
        message = 'Your account has been suspended. Please contact support.';
      } else if (e.code == 'operation-not-allowed') {
        message = 'Email/Password sign-in is not enabled. Please enable it in Firebase Console.';
      } else {
        message = 'Sign in failed (${e.code}): ${e.message}';
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Sign in failed: ${e.toString()}'};
    }
  }

  /// Sign in with Google
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // 1. Trigger Google Sign-In
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'success': false, 'message': 'Google sign in cancelled'};
      }

      // 2. Authenticate with Firebase using Google credentials
      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return {'success': false, 'message': 'Google authentication failed'};
      }

      // 3. Register or login in backend using Google user data
      final email = firebaseUser.email ?? '';
      final fullName = firebaseUser.displayName ?? 'User';

      final response = await HttpService.post(
        ApiEndpoints.googleAuth,
        data: {
          'id_token': googleAuth.idToken,
          'email': email,
          'full_name': fullName,
          'phone': firebaseUser.phoneNumber ?? '',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] && data['data'] != null) {
          final token = data['data']['token'];
          final user = data['data']['user'];

          // Save to local storage
          await StorageService.saveToken(token);
          await StorageService.saveUserId(user['id'].toString());
          await StorageService.saveUserRole(user['role'].toString());

          return {'success': true, 'data': data['data']};
        }
      }

      // If backend fails, sign out
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      return {
        'success': false,
        'message': response.data['message'] ?? 'Google sign in failed'
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      return {'success': false, 'message': 'Google authentication failed: ${e.message}'};
    } catch (e) {
      return {'success': false, 'message': 'Google sign in error: ${e.toString()}'};
    }
  }

  /// Sign out user
  static Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      await StorageService.clearAll();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  /// Get current Firebase user
  static firebase_auth.User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Listen to auth state changes
  static Stream<firebase_auth.User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }
}
