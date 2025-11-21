import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_expense_tracker/services/session_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  // Configure Firebase Auth settings for better emulator/debug compatibility
  AuthService() {
    _configureFirebaseAuth();
  }

  void _configureFirebaseAuth() {
    try {
      // CRITICAL: Disable app verification and ReCAPTCHA for mobile
      _firebaseAuth.setSettings(
        appVerificationDisabledForTesting: true,
        forceRecaptchaFlow: false,
      );
      
      if (kDebugMode) {
        print('✅ Firebase Auth configured successfully');
        print('   - App verification: DISABLED');
        print('   - ReCAPTCHA flow: DISABLED');
        print('   - Platform: ${Platform.operatingSystem}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Auth settings configuration warning: $e');
      }
    }
  }

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password, String fullName) async {
    try {
      if (kDebugMode) {
        print('🔐 Starting signup process...');
        print('   Email: $email');
        print('   Network: ${await _checkNetworkConnection()}');
      }
      
      // Create user with extended timeout for slow networks
      final userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          )
          .timeout(
            const Duration(seconds: 45),
            onTimeout: () {
              throw TimeoutException('Signup request timed out after 45 seconds. Please check your connection.');
            },
          );
          
      if (userCredential.user != null) {
        if (kDebugMode) {
          print('✅ User created successfully, updating profile...');
        }
        
        await userCredential.user!.updateDisplayName(fullName);
        await userCredential.user!.reload();
        
        // Save session data
        await SessionService.saveUserSession(
          email: email,
          displayName: fullName,
        );
        
        if (kDebugMode) {
          print('✅ Signup completed successfully for: $email');
        }
      }
      return userCredential;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('⏱️ Signup timeout: $e');
      }
      throw Exception('Request timed out. Please check your internet connection and try again.');
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ Firebase Auth Exception: ${e.code} - ${e.message}');
      }
      
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password is too weak. Please use a stronger password.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email address.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your internet connection.\n\nTroubleshooting:\n• Check if you have internet access\n• Try restarting the emulator\n• Disable VPN if enabled\n• Check DNS settings';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled. Please contact support.';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred during signup. Please try again.';
      }
      throw Exception(errorMessage);
    } on SocketException catch (e) {
      if (kDebugMode) {
        print('🔌 Socket Exception: $e');
      }
      throw Exception('No internet connection. Please check your network settings and try again.');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unexpected error during signup: $e');
      }
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<String> _checkNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 5),
      );
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return 'Connected ✓';
      }
      return 'No connection ✗';
    } catch (e) {
      return 'No connection ✗ ($e)';
    }
  }

  Future<void> updateUserProfile({required String fullName, File? imageFile}) async {
    try {
      String? photoURL;
      if (imageFile != null && currentUser != null) {
        final ref = _firebaseStorage.ref().child('user_avatars').child('${currentUser!.uid}.jpg');
        await ref.putFile(imageFile);
        photoURL = await ref.getDownloadURL();
      }

      if (currentUser != null) {
        await currentUser!.updateDisplayName(fullName);
        if (photoURL != null) {
          await currentUser!.updatePhotoURL(photoURL);
        }
        // Important: reload the user to get the updated info
        await _firebaseAuth.currentUser?.reload();
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("An error occurred while updating profile.");
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      if (kDebugMode) {
        print('🔐 Starting login process...');
        print('   Email: $email');
        print('   Network: ${await _checkNetworkConnection()}');
      }
      
      // Sign in with extended timeout for slow networks
      final result = await _firebaseAuth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password,
          )
          .timeout(
            const Duration(seconds: 45),
            onTimeout: () {
              throw TimeoutException('Login request timed out after 45 seconds. Please check your connection.');
            },
          );
      
      if (result.user != null) {
        if (kDebugMode) {
          print('✅ Sign in successful for: $email');
        }
        
        // Save session data on successful login
        await SessionService.saveUserSession(
          email: email,
          displayName: result.user!.displayName,
        );
      }
      
      return result;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('⏱️ Login timeout: $e');
      }
      throw Exception('Request timed out. Please check your internet connection and try again.');
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ Firebase Auth Exception: ${e.code} - ${e.message}');
      }
      
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email address.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid email or password. Please try again.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your internet connection.\n\nTroubleshooting:\n• Check if you have internet access\n• Try restarting the emulator\n• Disable VPN if enabled\n• Check DNS settings';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred during login. Please try again.';
      }
      throw Exception(errorMessage);
    } on SocketException catch (e) {
      if (kDebugMode) {
        print('🔌 Socket Exception: $e');
      }
      throw Exception('No internet connection. Please check your network settings and try again.');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unexpected error during login: $e');
      }
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> signOut() async {
    try {
      // Clear session data first
      await SessionService.clearUserSession();
      
      // Then sign out from Firebase
      await _firebaseAuth.signOut();
      
      if (kDebugMode) {
        print('User successfully signed out');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sign out error: $e');
      }
      throw Exception('Failed to sign out. Please try again.');
    }
  }

  // Helper method to check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Helper method to get user email
  String? get userEmail => currentUser?.email;

  // Helper method to get user display name
  String? get userDisplayName => currentUser?.displayName;

  // Helper method to get user photo URL
  String? get userPhotoURL => currentUser?.photoURL;

  // Helper method to reload current user
  Future<void> reloadUser() async {
    await currentUser?.reload();
  }
}

