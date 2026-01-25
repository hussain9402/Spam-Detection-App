import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spamdetection/features/authentication/views/login_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../widgets/custom_text_field.dart';
import '../controllers/signup_controller.dart';
import '../controllers/auth_controller.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SignUpController controller = Get.put(SignUpController());
    final AuthController authController = Get.find<AuthController>();

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    // Access the current theme's color scheme
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // Keep primary color for the top section
      backgroundColor: AppColors.primaryTeal,
      body: Stack(
        children: [
          // 1. Header Text Section
          SafeArea(
            
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    AppStrings.signUpTitle,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack, // SAME as Login
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.signUpDescription,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textBlack, // SAME as Login
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Adaptive Background Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).scaffoldBackgroundColor, // SAME as Login
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
                    const SizedBox(height: 10),

                    // Fields using theme-affected colors
                    Obx(
                      () => CustomTextField(
                        label: AppStrings.yourName,
                        controller: nameController,
                        hintText: AppStrings.nameHint,
                        errorText: controller.nameError.value.isEmpty
                            ? null
                            : controller.nameError.value,
                        onChanged: controller.validateName,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Obx(
                      () => CustomTextField(
                        label: AppStrings.yourEmail,
                        hintText: AppStrings.emailHint,
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
                        errorText: controller.emailError.value.isEmpty
                            ? null
                            : controller.emailError.value,
                        onChanged: controller.validateEmail,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Obx(
                      () => CustomTextField(
                        label: AppStrings.yourphone,
                        hintText: AppStrings.phoneHint,
                        keyboardType: TextInputType.phone,
                        controller: phoneController,
                        errorText: controller.phoneError.value.isEmpty
                            ? null
                            : controller.phoneError.value,
                        onChanged: controller.validatePhone,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Obx(
                      () => CustomTextField(
                        label: AppStrings.password,
                        hintText: AppStrings.passwordHint,
                        obscureText: true,
                        controller: passwordController,
                        errorText: controller.passwordError.value.isEmpty
                            ? null
                            : controller.passwordError.value,
                        onChanged: controller.validatePassword,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Obx(
                      () => CustomTextField(
                        label: AppStrings.confirmPassword,
                        obscureText: true,
                        hintText: AppStrings.confirmPasswordHint,
                        controller: confirmPasswordController,
                        errorText: controller.confirmPasswordError.value.isEmpty
                            ? null
                            : controller.confirmPasswordError.value,
                        onChanged: controller.validateConfirmPassword,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Primary Action Button
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
                              controller.isSignUpEnabled.value &&
                                  !authController.isLoading.value
                              ? () => controller.signUp()
                              : null,
                          child: authController.isLoading.value
                              ? CircularProgressIndicator(
                                  color: AppColors.textBlack,
                                )
                              : const Text(
                                  AppStrings.createAccount,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color:
                                        AppColors.primaryTeal, // SAME as Login
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Theme-affected Footer
                    Center(
                      child: TextButton(
                        onPressed: () => authController.navigateToLogin(),
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                            children: [
                              TextSpan(
                                text: AppStrings.logIn,
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
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Back Arrow
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
}
