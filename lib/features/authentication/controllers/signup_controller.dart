import 'package:get/get.dart';
import '../../../core/utils/validators.dart';
import 'auth_controller.dart';
import '../../../core/routes/app_routes.dart';

class SignUpController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  
  // Form fields
  final RxString name = ''.obs;
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxString confirmPassword = ''.obs;
  
  // Error messages
  final RxString nameError = ''.obs;
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString confirmPasswordError = ''.obs;
  final RxString generalError = ''.obs;
  
  // Button state
  RxBool get isSignUpEnabled => (name.value.isNotEmpty && 
                                  email.value.isNotEmpty && 
                                  password.value.isNotEmpty && 
                                  confirmPassword.value.isNotEmpty && 
                                  nameError.value.isEmpty && 
                                  emailError.value.isEmpty && 
                                  passwordError.value.isEmpty && 
                                  confirmPasswordError.value.isEmpty &&
                                  !_authController.isLoading.value).obs;
  
  // Validate name
  void validateName(String value) {
    name.value = value;
    final error = Validators.validateName(value);
    nameError.value = error ?? '';
    if (error == null) {
      generalError.value = '';
    }
  }
  
  // Validate email (real-time)
  void validateEmail(String value) {
    email.value = value;
    if (value.isEmpty) {
      emailError.value = '';
      return;
    }
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
    
    // Re-validate confirm password if it's not empty
    if (confirmPassword.value.isNotEmpty) {
      validateConfirmPassword(confirmPassword.value);
    }
    if (error == null) {
      generalError.value = '';
    }
  }
  
  // Validate confirm password
  void validateConfirmPassword(String value) {
    confirmPassword.value = value;
    final error = Validators.validateConfirmPassword(value, password.value);
    confirmPasswordError.value = error ?? '';
    if (error == null) {
      generalError.value = '';
    }
  }
  
  // Handle signup
  Future<void> signUp() async {
    // Validate all fields
    validateName(name.value);
    validateEmail(email.value);
    validatePassword(password.value);
    validateConfirmPassword(confirmPassword.value);
    
    if (nameError.value.isEmpty && 
        emailError.value.isEmpty && 
        passwordError.value.isEmpty && 
        confirmPasswordError.value.isEmpty) {
      generalError.value = '';
      final success = await _authController.handleEmailSignup(
        name.value, 
        email.value, 
        password.value,
      );
      
      if (!success) {
        generalError.value = _authController.errorMessage.value;
        // Show error snackbar
        Get.snackbar(
          'Sign Up Failed',
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
}
