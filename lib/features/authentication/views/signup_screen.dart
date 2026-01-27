import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart'; // Import added
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

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.primaryTeal,
      // 1. Prevents the screen from moving up when keyboard opens, 
      // keeping the loader in the true center of the glass.
      resizeToAvoidBottomInset: false, 
      body: Obx(
        () => Stack(
          children: [
            // --- MAIN UI ---
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // --- 1. Top Header Section ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        AppStrings.signUpTitle,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                  ),

                  // --- 2. Main Content Card ---
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
                        // 2. Adjust padding so the user can still scroll to see 
                        // bottom fields when keyboard is visible
                        padding: EdgeInsets.only(
                          left: 24.0,
                          right: 24.0,
                          top: 24.0,
                          bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            // Form Fields
                            _buildFields(controller, nameController, emailController, 
                                        phoneController, passwordController, confirmPasswordController),
                            
                            const SizedBox(height: 32),

                            // Sign Up Button (Clean logic without inner loader)
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.backgroundDark,
                                  disabledBackgroundColor: AppColors.backgroundDark,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: const BorderSide(color: AppColors.primaryTeal, width: 1.5),
                                  ),
                                ),
                                onPressed: controller.isSignUpEnabled.value
                                    ? () => controller.signUp()
                                    : null,
                                child: const Text(
                                  AppStrings.createAccount,
                                  style: TextStyle(fontSize: 18, color: AppColors.primaryTeal),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Footer
                            _buildFooter(authController, colorScheme),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- 3. FULL SCREEN OVERLAY ---
            if (authController.isLoading.value)
              Positioned.fill(
                child: AbsorbPointer( // Disables all clicks on the form
                  child: Container(
                    color: Colors.black.withOpacity(0.5), // Dim effect
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

  // Helper methods to keep the build method clean
  Widget _buildFields(SignUpController controller, var name, var email, var phone, var pass, var confirm) {
    return Column(
      children: [
        CustomTextField(
          label: AppStrings.yourName,
          controller: name,
          hintText: AppStrings.nameHint,
          errorText: controller.nameError.value.isEmpty ? null : controller.nameError.value,
          onChanged: controller.validateName,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: AppStrings.yourEmail,
          hintText: AppStrings.emailHint,
          keyboardType: TextInputType.emailAddress,
          controller: email,
          errorText: controller.emailError.value.isEmpty ? null : controller.emailError.value,
          onChanged: controller.validateEmail,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: AppStrings.yourphone,
          hintText: AppStrings.phoneHint,
          keyboardType: TextInputType.phone,
          controller: phone,
          errorText: controller.phoneError.value.isEmpty ? null : controller.phoneError.value,
          onChanged: controller.validatePhone,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: AppStrings.password,
          hintText: AppStrings.passwordHint,
          obscureText: true,
          controller: pass,
          errorText: controller.passwordError.value.isEmpty ? null : controller.passwordError.value,
          onChanged: controller.validatePassword,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: AppStrings.confirmPassword,
          obscureText: true,
          hintText: AppStrings.confirmPasswordHint,
          controller: confirm,
          errorText: controller.confirmPasswordError.value.isEmpty ? null : controller.confirmPasswordError.value,
          onChanged: controller.validateConfirmPassword,
        ),
      ],
    );
  }

  Widget _buildFooter(AuthController authController, ColorScheme colorScheme) {
    return Center(
      child: TextButton(
        onPressed: () => authController.navigateToLogin(),
        child: RichText(
          text: TextSpan(
            text: "Already have an account? ",
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
            children: const [
              TextSpan(
                text: AppStrings.logIn,
                style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}