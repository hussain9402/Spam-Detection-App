import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // Ensure you added this to pubspec.yaml

import '../models/user_model.dart';
import '../../../core/routes/app_routes.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final box = GetStorage(); // Local cache for the phone number

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isAuthenticated = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

@override
void onInit() {
  super.onInit();

  _auth.authStateChanges().listen((User? user) async {
    // 1. Check if "Remember Me" was saved in local storage
    bool shouldRemember = box.read('remember_me') ?? false;

    if (user != null) {
      if (shouldRemember) {
        await _fetchUserAndCache(user);
      } else {
        // If not remembered, treat as unauthenticated for auto-navigation
        // but don't force logout here to avoid infinite loops during login
        isAuthenticated.value = false;
      }
    } else {
      _clearUserSession();
    }
  });
}

  // ------------------- SESSION MANAGEMENT -------------------

  // Fetches extra data (phone) from Firestore and saves to local cache
  Future<void> _fetchUserAndCache(User user) async {
    const tag = 'FirestoreRead.users';
    try {
      final path = 'users/${user.uid}';
      log('GET $path', name: tag);
      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();

      String phone = '';
      String name = user.displayName ?? '';

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        log('Doc $path exists. Raw data: $data', name: tag);
        phone = data['phone'] ?? data['phoneNumber'] ?? '';
        name = data['name'] ?? name;
        log(
          'Parsed → name: "$name", phone: "$phone", email: ${user.email}',
          name: tag,
        );
        box.write('user_phone', phone);
      } else {
        log('Doc $path does not exist (no Firestore profile yet)', name: tag);
      }

      currentUser.value = UserModel(
        id: user.uid,
        name: name,
        email: user.email ?? '',
        photoUrl: user.photoURL,
        phoneNumber: phone,
      );

      log(
        'currentUser cached → phoneNumber: "${currentUser.value?.phoneNumber}"',
        name: tag,
      );
      isAuthenticated.value = true;
    } catch (e) {
      log("Error fetching user session: $e");
    }
  }

  void _clearUserSession() {
    currentUser.value = null;
    isAuthenticated.value = false;
    box.remove('user_phone'); // Clean cache on logout
  }

  // Getter for the cached phone number
  String get cachedPhoneNumber => box.read('user_phone') ?? '';

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

      if (userCredential.user != null) {
        // Fetch user data immediately after login success
        await _fetchUserAndCache(userCredential.user!);
        isLoading.value = false;
        return true;
      }

      isLoading.value = false;
      return false;
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
    required String phone,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        isLoading.value = false;
        return false;
      }

      try {
        await user.updateDisplayName(name);
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } on FirebaseException catch (e) {
        try {
          await user.delete();
        } catch (_) {
          /* ignore rollback failure */
        }
        isLoading.value = false;
        if (e.code == 'permission-denied') {
          errorMessage.value =
              'Could not save your profile (Firestore permission denied). '
              'Deploy firestore.rules from this project: firebase deploy --only firestore:rules';
        } else {
          errorMessage.value =
              'Could not save your profile. Please try again.';
        }
        return false;
      }

      await _auth.signOut();
      _clearUserSession();

      isLoading.value = false;
      return true;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      errorMessage.value = _getErrorMessage(e.code);
      return false;
    } catch (e) {
      log('handleEmailSignup error: $e');
      isLoading.value = false;
      errorMessage.value = 'An unexpected error occurred. Please try again.';
      return false;
    }
  }
  // ------------------- LOGOUT -------------------
  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _auth.signOut();
      _clearUserSession();
      isLoading.value = false;
      Get.offAllNamed(AppRoutes.onboarding);
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to logout. Please try again.';
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password': return 'The password provided is too weak.';
      case 'email-already-in-use': return 'An account already exists for that email.';
      case 'invalid-email': return 'The email address is invalid.';
      case 'user-not-found': return 'No user found for that email.';
      case 'wrong-password': return 'Wrong password provided.';
      case 'network-request-failed': return 'Network error. Check your connection.';
      default: return 'Authentication failed. Please try again.';
    }
  }
}