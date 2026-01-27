import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../widgets/custom_text_field.dart';
import '../controllers/login_controller.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());
    final AuthController authController = Get.find<AuthController>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.primaryTeal,
      resizeToAvoidBottomInset: false,
      // We use Obx here to listen for the isLoading state globally for this screen
      body: Obx(
        () => Stack(
          children: [
            // 1. The Main UI
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // --- Header Section ---
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        AppStrings.loginTitle,
                        style: const TextStyle(
                          color: AppColors.textBlack,
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // --- Main Content Card ---
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),

                            // Email Field
                            CustomTextField(
                              label: AppStrings.yourEmail,
                              keyboardType: TextInputType.emailAddress,
                              controller: emailController,
                              hintText: AppStrings.emailHint,
                              errorText: controller.emailError.value.isEmpty
                                  ? null
                                  : controller.emailError.value,
                              onChanged: (value) =>
                                  controller.validateEmail(value),
                            ),
                            const SizedBox(height: 24),

                            // Password Field
                            CustomTextField(
                              label: AppStrings.password,
                              obscureText: true,
                              controller: passwordController,
                              hintText: AppStrings.passwordHint,
                              errorText: controller.passwordError.value.isEmpty
                                  ? null
                                  : controller.passwordError.value,
                              onChanged: (value) =>
                                  controller.validatePassword(value),
                            ),

                            const SizedBox(height: 16),

                            // Remember Me
                            Row(
                              children: [
                                Checkbox(
                                  value: controller.rememberMe.value,
                                  onChanged: (value) =>
                                      controller.rememberMe.value =
                                          value ?? false,
                                  activeColor: AppColors.primaryTeal,
                                  checkColor: AppColors.backgroundDark,
                                ),
                                Text(
                                  AppStrings.rememberMe,
                                  style: TextStyle(
                                    color: colorScheme.onSurface.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.backgroundDark,
                                  disabledForegroundColor: AppColors.backgroundDark,
                                  disabledBackgroundColor:
                                      AppColors.backgroundDark,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: const BorderSide(
                                      color: AppColors.primaryTeal,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                onPressed: controller.isLoginEnabled.value
                                    ? () => controller.login()
                                    : null,
                                child: const Text(
                                  AppStrings.loginButton,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColors.primaryTeal,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),
                            // Footer Links...
                            Center(
                              child: TextButton(
                                onPressed: () =>
                                    authController.navigateToSignup(),
                                child: RichText(
                                  text: TextSpan(
                                    text: "Don't have an account? ",
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withOpacity(
                                        0.6,
                                      ),
                                    ),
                                    children: const [
                                      TextSpan(
                                        text: AppStrings.signUp,
                                        style: TextStyle(
                                          color: AppColors.primaryTeal,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. The Loading Overlay
           if (authController.isLoading.value)
          Positioned.fill( // This makes the overlay cover the ENTIRE screen
            child: AbsorbPointer( // Blocks all clicks to the UI below
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: LoadingAnimationWidget.waveDots(
                    color: AppColors.primaryTeal,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
