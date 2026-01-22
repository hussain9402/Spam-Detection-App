import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages

import '../models/user_model.dart';
import '../../../core/routes/app_routes.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isAuthenticated = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        currentUser.value = UserModel(
          id: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          photoUrl: user.photoURL,
        );
        isAuthenticated.value = true;
      } else {
        currentUser.value = null;
        isAuthenticated.value = false;
      }
    });
  }

  // ------------------- NAVIGATION -------------------
  void navigateToOnboarding() => Get.offNamed(AppRoutes.onboarding);
  void navigateToLogin() => Get.toNamed(AppRoutes.login);
  void navigateToSignup() => Get.toNamed(AppRoutes.signup);

  // ------------------- EMAIL LOGIN -------------------
  Future<bool> handleEmailLogin(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      isLoading.value = false;

      return userCredential.user != null;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      errorMessage.value = _getErrorMessage(e.code);
      return false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'An unexpected error occurred. Please try again.';
      return false;
    }
  }

  // ------------------- EMAIL SIGNUP WITH PHONE -------------------
  Future<bool> handleEmailSignup({
    required String name,
    required String email,
    required String password,
    required String phone, // phone number added
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Create user with email and password
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.reload();

        // Save extra user info (name + phone) in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'uid': userCredential.user!.uid,
          'name': name,
          'email': email,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      isLoading.value = false;
      return true;

    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      log('Error during email signup: ${e.message}');
      errorMessage.value = _getErrorMessage(e.code);
      return false;
    } catch (e) {
      isLoading.value = false;
      log('Error during email signup: $e');
      errorMessage.value = '$e';
      errorMessage.value = 'An unexpected error occurred. Please try again.';
      return false;
    }
  }

  // ------------------- PASSWORD RESET -------------------
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _auth.sendPasswordResetEmail(email: email);

      isLoading.value = false;
      return true;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      errorMessage.value = _getErrorMessage(e.code);
      return false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to send password reset email. Please try again.';
      return false;
    }
  }

  // ------------------- LOGOUT -------------------
  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _auth.signOut();
      currentUser.value = null;
      isAuthenticated.value = false;
      isLoading.value = false;
      Get.offAllNamed(AppRoutes.onboarding);
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to logout. Please try again.';
    }
  }

  // ------------------- ERROR HANDLER -------------------
  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
