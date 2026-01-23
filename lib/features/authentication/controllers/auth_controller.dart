import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

    // Listen to auth state changes and fetch Firestore details automatically
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _fetchUserAndCache(user);
      } else {
        _clearUserSession();
      }
    });
  }

  // ------------------- SESSION MANAGEMENT -------------------

  // Fetches extra data (phone) from Firestore and saves to local cache
  Future<void> _fetchUserAndCache(User user) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      
      String phone = '';
      String name = user.displayName ?? '';

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        // Use 'phone' as per your signup logic key
        phone = data['phone'] ?? '';
        name = data['name'] ?? name;
        
        // Save to local cache for ChatController
        box.write('user_phone', phone);
      }

      currentUser.value = UserModel(
        id: user.uid,
        name: name,
        email: user.email ?? '',
        photoUrl: user.photoURL,
        phoneNumber: phone, // Satisfies the required field in UserModel
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
    required String phone,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.reload();

        // 1. Save phone number and name in Firestore
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'uid': userCredential.user!.uid,
          'name': name,
          'email': email,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 2. Cache the phone immediately for the current session
        box.write('user_phone', phone);
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