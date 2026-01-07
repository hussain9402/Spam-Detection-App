import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Social login imports - COMMENTED OUT (only using email/password for now)
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../models/user_model.dart';
import '../../../core/routes/app_routes.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn(); // COMMENTED OUT - social login disabled
  
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
  
  // Navigate to onboarding screen
  void navigateToOnboarding() {
    Get.offNamed(AppRoutes.onboarding);
  }
  
  // Navigate to login screen
  void navigateToLogin() {
    Get.toNamed(AppRoutes.login);
  }
  
  // Navigate to signup screen
  void navigateToSignup() {
    Get.toNamed(AppRoutes.signup);
  }
  
  // Handle email login
  Future<bool> handleEmailLogin(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      isLoading.value = false;
      
      if (userCredential.user != null) {
        // Navigation will be handled by auth state listener
        return true;
      }
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
  
  // Handle email signup
  Future<bool> handleEmailSignup(String name, String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.reload();
      }
      
      isLoading.value = false;
      
      if (userCredential.user != null) {
        // Navigation will be handled by auth state listener
        return true;
      }
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
  
  // Handle Google Sign In - COMMENTED OUT (only using email/password for now)
  // Future<bool> handleGoogleSignIn() async {
  //   try {
  //     isLoading.value = true;
  //     errorMessage.value = '';
  //     
  //     // Trigger the authentication flow
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //     
  //     if (googleUser == null) {
  //       // User canceled the sign-in
  //       isLoading.value = false;
  //       return false;
  //     }
  //     
  //     // Obtain the auth details from the request
  //     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  //     
  //     // Create a new credential
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //     
  //     // Sign in to Firebase with the Google credential
  //     final UserCredential userCredential = await _auth.signInWithCredential(credential);
  //     
  //     isLoading.value = false;
  //     
  //     if (userCredential.user != null) {
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     isLoading.value = false;
  //     errorMessage.value = 'Google sign in failed. Please try again.';
  //     return false;
  //   }
  // }
  
  // Handle Facebook Sign In - COMMENTED OUT (only using email/password for now)
  // Future<bool> handleFacebookSignIn() async {
  //   try {
  //     isLoading.value = true;
  //     errorMessage.value = '';
  //     
  //     // Trigger the sign-in flow
  //     final LoginResult result = await FacebookAuth.instance.login();
  //     
  //     if (result.status == LoginStatus.success) {
  //       // Create a credential from the access token
  //       final OAuthCredential facebookAuthCredential = 
  //           FacebookAuthProvider.credential(result.accessToken!.tokenString);
  //       
  //       // Sign in to Firebase with the Facebook credential
  //       final UserCredential userCredential = 
  //           await _auth.signInWithCredential(facebookAuthCredential);
  //       
  //       isLoading.value = false;
  //       
  //       if (userCredential.user != null) {
  //         return true;
  //       }
  //     } else {
  //       isLoading.value = false;
  //       errorMessage.value = 'Facebook sign in was cancelled or failed.';
  //       return false;
  //     }
  //     return false;
  //   } catch (e) {
  //     isLoading.value = false;
  //     errorMessage.value = 'Facebook sign in failed. Please try again.';
  //     return false;
  //   }
  // }
  
  // Handle Apple Sign In - COMMENTED OUT (only using email/password for now)
  // Future<bool> handleAppleSignIn() async {
  //   try {
  //     isLoading.value = true;
  //     errorMessage.value = '';
  //     
  //     // Request credential for the currently signed in Apple account
  //     final appleCredential = await SignInWithApple.getAppleIDCredential(
  //       scopes: [
  //         AppleIDAuthorizationScopes.email,
  //         AppleIDAuthorizationScopes.fullName,
  //       ],
  //     );
  //     
  //     // Create an `OAuthCredential` from the credential returned by Apple
  //     final oauthCredential = OAuthProvider("apple.com").credential(
  //       idToken: appleCredential.identityToken,
  //       accessToken: appleCredential.authorizationCode,
  //     );
  //     
  //     // Sign in to Firebase with the Apple credential
  //     final UserCredential userCredential = await _auth.signInWithCredential(oauthCredential);
  //     
  //     // Update display name if available
  //     if (userCredential.user != null && 
  //         appleCredential.givenName != null && 
  //         appleCredential.familyName != null) {
  //       final displayName = '${appleCredential.givenName} ${appleCredential.familyName}';
  //       await userCredential.user!.updateDisplayName(displayName);
  //       await userCredential.user!.reload();
  //     }
  //     
  //     isLoading.value = false;
  //     
  //     if (userCredential.user != null) {
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     isLoading.value = false;
  //     errorMessage.value = 'Apple sign in failed. Please try again.';
  //     return false;
  //   }
  // }
  
  // Handle social login - COMMENTED OUT (only using email/password for now)
  // Future<bool> handleSocialLogin(String provider) async {
  //   switch (provider.toLowerCase()) {
  //     case 'google':
  //       return await handleGoogleSignIn();
  //     case 'facebook':
  //       return await handleFacebookSignIn();
  //     case 'apple':
  //       return await handleAppleSignIn();
  //     default:
  //       errorMessage.value = 'Unknown provider: $provider';
  //       return false;
  //   }
  // }
  
  // Send password reset email
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
  
  // Logout
  Future<void> logout() async {
    try {
      isLoading.value = true;
      // await _googleSignIn.signOut(); // COMMENTED OUT - social login disabled
      // await FacebookAuth.instance.logOut(); // COMMENTED OUT - social login disabled
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
  
  // Get user-friendly error message
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
