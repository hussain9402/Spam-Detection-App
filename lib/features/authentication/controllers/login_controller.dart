import 'package:get/get.dart';
import '../../../core/utils/validators.dart';
import 'auth_controller.dart';
import '../../../core/routes/app_routes.dart';

class LoginController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  
  // Form fields
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  
  // Error messages
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString generalError = ''.obs;
  
  // Button state
  RxBool get isLoginEnabled => (email.value.isNotEmpty && 
                                password.value.isNotEmpty && 
                                emailError.value.isEmpty && 
                                passwordError.value.isEmpty &&
                                !_authController.isLoading.value).obs;
  
  // Validate email
  void validateEmail(String value) {
    email.value = value;
    final error = Validators.validateEmail(value);
    emailError.value = error ?? '';
    if (error == null) {
      generalError.value = '';
    }
  }
  
  // Validate password
  void validatePassword(String value) {
    password.value = value;
    final error = Validators.validatePassword(value);
    passwordError.value = error ?? '';
    if (error == null) {
      generalError.value = '';
    }
  }
  
  // Handle login
  Future<void> login() async {
    // Validate all fields
    validateEmail(email.value);
    validatePassword(password.value);
    
    if (emailError.value.isEmpty && passwordError.value.isEmpty) {
      generalError.value = '';
      final success = await _authController.handleEmailLogin(
        email.value, 
        password.value,
      );
      
      if (!success) {
        generalError.value = _authController.errorMessage.value;
        // Show error snackbar
        Get.snackbar(
          'Login Failed',
          _authController.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Success - navigation handled by auth state listener
        Get.offAllNamed(AppRoutes.mainNavigation);
      }
    }
  }
  
  // Handle social login - COMMENTED OUT (keeping only email/password)
  // Future<void> socialLogin(String provider) async {
  //   generalError.value = '';
  //   final success = await _authController.handleSocialLogin(provider);
  //   
  //   if (!success) {
  //     generalError.value = _authController.errorMessage.value;
  //     // Show error snackbar
  //     Get.snackbar(
  //       'Sign In Failed',
  //       _authController.errorMessage.value,
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //   } else {
  //     // Success - navigation handled by auth state listener
  //     Get.offAllNamed(AppRoutes.home);
  //   }
  // }
  
  // Navigate to signup
  void navigateToSignup() {
    _authController.navigateToSignup();
  }
  
  // Navigate to forgot password
  Future<void> navigateToForgotPassword() async {
    if (email.value.isEmpty || emailError.value.isNotEmpty) {
      Get.snackbar(
        'Email Required',
        'Please enter a valid email address first.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    // final success = await _authController.sendPasswordResetEmail(email.value);
    
    // if (success) {
    //   Get.snackbar(
    //     'Password Reset Email Sent',
    //     'Please check your email for password reset instructions.',
    //     snackPosition: SnackPosition.BOTTOM,
    //   );
    // } else {
    //   Get.snackbar(
    //     'Failed',
    //     _authController.errorMessage.value,
    //     snackPosition: SnackPosition.BOTTOM,
    //   );
    // }
  }
}
