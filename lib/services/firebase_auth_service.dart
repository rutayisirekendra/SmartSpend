import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password, String fullName) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(fullName);
        await userCredential.user!.reload();
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
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
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

