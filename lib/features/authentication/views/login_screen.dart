import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spamdetection/features/authentication/views/signup_screen.dart';
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
    RxBool rememberMe = false.obs;

    void toggleRememberMe(bool? value) {
      rememberMe.value = value ?? false;
    }

    return Scaffold(
      backgroundColor: AppColors.primaryTeal, // Header background color
  
      body: Stack(
        children: [
          // 1. Header Text Section
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 40.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.loginTitle, // Or "Log in" to match your logic
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.loginWelcome,
                    style: TextStyle(fontSize: 14, color: AppColors.textBlack),
                  ),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height:
                  MediaQuery.of(context).size.height *
                  0.80, // Occupies 75% of screen
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Email Field
                    Obx(
                      () => CustomTextField(
                        label: AppStrings.yourEmail,
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
                        hintText: AppStrings.emailHint,
                        errorText: controller.emailError.value.isEmpty
                            ? null
                            : controller.emailError.value,
                        onChanged: (value) => controller.validateEmail(value),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Password Field
                    Obx(
                      () => CustomTextField(
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
                    ),

                    const SizedBox(height: 16),
                    // Remember Me Checkbox (New addition from UI)
                    Obx(
                      () => Row(
                        children: [
                          Checkbox(
                            value: controller.rememberMe.value,
                            onChanged: (value) {
                              controller.rememberMe.value = value ?? false;
                            },
                            activeColor: AppColors.primaryTeal,
                            checkColor: AppColors.backgroundDark,
                          ),
                          Text(
                            AppStrings.rememberMe,
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Login Button (Styled to match orange button in UI)
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 55,

                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.backgroundDark,

                            disabledBackgroundColor: AppColors.backgroundDark,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(
                                color: AppColors.primaryTeal, // 👈 Border color
                                width: 1.5, // 👈 Border width
                              ),
                            ),
                          ),
                          onPressed:
                              controller.isLoginEnabled.value &&
                                  !authController.isLoading.value
                              ? () => controller.login()
                              : null,
                          child: authController.isLoading.value
                              ? CircularProgressIndicator(
                                  color: AppColors.textBlack,
                                )
                              : const Text(
                                  AppStrings.loginButton,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColors.primaryTeal,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    // "Or" Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: colorScheme.onSurface.withOpacity(0.3),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Or",
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: colorScheme.onSurface.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    // Social Icons (Icons only layout)

                    // Footer Link
                    Center(
                      child: TextButton(
                        onPressed: () => authController.navigateToSignup(),
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                            children: [
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

          // Back Button
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }
}
