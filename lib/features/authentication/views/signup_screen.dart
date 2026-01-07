import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textBlack),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            // Title with underline
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
                children: [
                  const TextSpan(text: 'Sign up with '),
                  WidgetSpan(
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.primaryTeal,
                            width: 3,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Description
            Text(
              AppStrings.signUpDescription,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGray,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            // Name Field
            Obx(() => CustomTextField(
              label: AppStrings.yourName,
              controller: nameController,
              errorText: controller.nameError.value.isEmpty ? null : controller.nameError.value,
              onChanged: (value) => controller.validateName(value),
            )),
            const SizedBox(height: 24),
            // Email Field with real-time validation
            Obx(() => CustomTextField(
              label: AppStrings.yourEmail,
              keyboardType: TextInputType.emailAddress,
              controller: emailController,
              errorText: controller.emailError.value.isEmpty ? null : controller.emailError.value,
              onChanged: (value) => controller.validateEmail(value),
            )),
            const SizedBox(height: 24),
            // Password Field
            Obx(() => CustomTextField(
              label: AppStrings.password,
              obscureText: true,
              controller: passwordController,
              errorText: controller.passwordError.value.isEmpty ? null : controller.passwordError.value,
              onChanged: (value) => controller.validatePassword(value),
            )),
            const SizedBox(height: 24),
            // Confirm Password Field
            Obx(() => CustomTextField(
              label: AppStrings.confirmPassword,
              obscureText: true,
              controller: confirmPasswordController,
              errorText: controller.confirmPasswordError.value.isEmpty ? null : controller.confirmPasswordError.value,
              onChanged: (value) => controller.validateConfirmPassword(value),
            )),
            const SizedBox(height: 32),
            // Create Account Button
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isSignUpEnabled.value && !authController.isLoading.value
                    ? () => controller.signUp()
                    : null,
                child: authController.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.textWhite),
                        ),
                      )
                    : const Text(
                        AppStrings.createAccount,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            )),
            // General Error Message
            Obx(() => controller.generalError.value.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      controller.generalError.value,
                      style: const TextStyle(
                        color: AppColors.errorRed,
                        fontSize: 12,
                      ),
                    ),
                  )
                : const SizedBox.shrink()),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

