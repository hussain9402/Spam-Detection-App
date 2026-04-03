import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/validators.dart';
import 'auth_controller.dart';
import '../../../core/routes/app_routes.dart';

class SignUpController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  late final TextEditingController nameTextController;
  late final TextEditingController emailTextController;
  late final TextEditingController phoneTextController;
  late final TextEditingController passwordTextController;
  late final TextEditingController confirmPasswordTextController;

  @override
  void onInit() {
    super.onInit();
    nameTextController = TextEditingController();
    emailTextController = TextEditingController();
    phoneTextController = TextEditingController();
    passwordTextController = TextEditingController();
    confirmPasswordTextController = TextEditingController();
  }

  @override
  void onClose() {
    nameTextController.dispose();
    emailTextController.dispose();
    phoneTextController.dispose();
    passwordTextController.dispose();
    confirmPasswordTextController.dispose();
    super.onClose();
  }

  // Form fields
  final RxString name = ''.obs;
  final RxString email = ''.obs;
  final RxString phone = ''.obs;
  final RxString password = ''.obs;
  final RxString confirmPassword = ''.obs;

  // Error messages
  final RxString nameError = ''.obs;
  final RxString emailError = ''.obs;
  final RxString phoneError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString confirmPasswordError = ''.obs;
  final RxString generalError = ''.obs;

  /// Used inside [Obx]; reads reactive fields so the button rebuilds when they change.
  bool get isSignUpEnabled =>
      name.value.isNotEmpty &&
      email.value.isNotEmpty &&
      phone.value.isNotEmpty &&
      password.value.isNotEmpty &&
      confirmPassword.value.isNotEmpty &&
      nameError.value.isEmpty &&
      emailError.value.isEmpty &&
      phoneError.value.isEmpty &&
      passwordError.value.isEmpty &&
      confirmPasswordError.value.isEmpty &&
      !_authController.isLoading.value;

  // ---------------- VALIDATIONS ----------------
  void validateName(String value) {
    name.value = value;
    final error = Validators.validateName(value);
    nameError.value = error ?? '';
    if (error == null) generalError.value = '';
  }

  void validateEmail(String value) {
    email.value = value;
    if (value.isEmpty) {
      emailError.value = '';
      return;
    }
    final error = Validators.validateEmail(value);
    emailError.value = error ?? '';
    if (error == null) generalError.value = '';
  }

  void validatePhone(String value) {
    phone.value = value.trim();

    if (phone.value.isEmpty) {
      phoneError.value = 'Phone number is required';
    } else if (!phone.value.startsWith('+') || phone.value.length < 10) {
      phoneError.value = 'Use country code (e.g. +923001234567)';
    } else {
      phoneError.value = '';
      generalError.value = '';
    }
  }

  void validatePassword(String value) {
    password.value = value;
    final error = Validators.validatePassword(value);
    passwordError.value = error ?? '';

    if (confirmPassword.value.isNotEmpty) {
      validateConfirmPassword(confirmPassword.value);
    }
    if (error == null) generalError.value = '';
  }

  void validateConfirmPassword(String value) {
    confirmPassword.value = value;
    final error =
        Validators.validateConfirmPassword(value, password.value);
    confirmPasswordError.value = error ?? '';
    if (error == null) generalError.value = '';
  }

  // ---------------- SIGN UP ----------------
  Future<void> signUp() async {
    validateName(nameTextController.text);
    validateEmail(emailTextController.text);
    validatePhone(phoneTextController.text);
    validatePassword(passwordTextController.text);
    validateConfirmPassword(confirmPasswordTextController.text);

    if (nameError.value.isEmpty &&
        emailError.value.isEmpty &&
        phoneError.value.isEmpty &&
        passwordError.value.isEmpty &&
        confirmPasswordError.value.isEmpty) {
      generalError.value = '';

      final success = await _authController.handleEmailSignup(
        name: name.value,
        email: email.value,
        password: password.value,
        phone: normalizePhone(phone.value),
      );

      if (!success) {
        generalError.value = _authController.errorMessage.value;
        Get.snackbar(
          'Sign Up Failed',
          _authController.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
       Get.snackbar('Success', 'Account created. Please login.');
      Get.offAllNamed(AppRoutes.login);
      }
    }
  }

  // ---------------- HELPERS ----------------
  String normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'\s|-'), '');
  }
}
