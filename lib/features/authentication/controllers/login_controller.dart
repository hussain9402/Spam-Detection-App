import 'package:get/get.dart';
import '../../../core/utils/validators.dart';
import 'auth_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../chat/controllers/chat_controller.dart';

class LoginController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  // Form fields
  final RxString email = ''.obs;
  final RxString password = ''.obs;

  // Error messages
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString generalError = ''.obs;

  // Checkbox state
  final RxBool rememberMe = false.obs;

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  // Button state - reactive to input and auth loading status
  RxBool get isLoginEnabled => (
    email.value.isNotEmpty &&
    password.value.isNotEmpty &&
    emailError.value.isEmpty &&
    passwordError.value.isEmpty &&
    !_authController.isLoading.value
  ).obs;

  // Validate email
  void validateEmail(String value) {
    email.value = value.trim();
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
    // 1. Final validation check
    validateEmail(email.value);
    validatePassword(password.value);

    if (emailError.value.isEmpty && passwordError.value.isEmpty) {
      generalError.value = '';
      
      // 2. Persist the "Remember Me" choice to GetStorage via AuthController
      // This is used by the SplashScreen to decide whether to auto-login or force-logout
      _authController.box.write('remember_me', rememberMe.value);

      // 3. Attempt Login
      final success = await _authController.handleEmailLogin(
        email.value,
        password.value,
      );

      if (success) {
        // Immediately trigger chat fetching now that user data is loaded
        if (Get.isRegistered<ChatController>()) {
          Get.find<ChatController>().listenToMyChats();
        }

        // 4. Navigate to Main App
        Get.offAllNamed(AppRoutes.mainNavigation);
      } else {
        // 5. Handle failure
        generalError.value = _authController.errorMessage.value;
        Get.snackbar(
          'Login Failed',
          _authController.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  // Navigate to signup
  void navigateToSignup() {
    _authController.navigateToSignup();
  }

  // Navigate to forgot password (Placeholder logic)
  Future<void> navigateToForgotPassword() async {
    if (email.value.isEmpty || emailError.value.isNotEmpty) {
      Get.snackbar(
        'Email Required',
        'Please enter a valid email address first.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    // Logic for sending password reset email goes here
  }
}