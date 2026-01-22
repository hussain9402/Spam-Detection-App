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
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            // -------- Title --------
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
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
                      child: Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // -------- Description --------
            Text(
              AppStrings.signUpDescription,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.7),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // -------- Name --------
            Obx(() => CustomTextField(
                  label: AppStrings.yourName,
                  
                  controller: nameController,
                  errorText: controller.nameError.value.isEmpty
                      ? null
                      : controller.nameError.value,
                  onChanged: controller.validateName,
                )),

            const SizedBox(height: 24),

            // -------- Email --------
            Obx(() => CustomTextField(
                  label: AppStrings.yourEmail,
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  errorText: controller.emailError.value.isEmpty
                      ? null
                      : controller.emailError.value,
                  onChanged: controller.validateEmail,
                )),

            const SizedBox(height: 24),

            // -------- Phone Number --------
            Obx(() => CustomTextField(
                  label: 'Phone Number',
                  hintText: '+923001234567',
                  keyboardType: TextInputType.phone,
                  controller: phoneController,
                  errorText: controller.phoneError.value.isEmpty
                      ? null
                      : controller.phoneError.value,
                  onChanged: controller.validatePhone,
                )),

            const SizedBox(height: 24),

            // -------- Password --------
            Obx(() => CustomTextField(
                  label: AppStrings.password,
                  obscureText: true,
                  controller: passwordController,
                  errorText: controller.passwordError.value.isEmpty
                      ? null
                      : controller.passwordError.value,
                  onChanged: controller.validatePassword,
                )),

            const SizedBox(height: 24),

            // -------- Confirm Password --------
            Obx(() => CustomTextField(
                  label: AppStrings.confirmPassword,
                  obscureText: true,
                  controller: confirmPasswordController,
                  errorText:
                      controller.confirmPasswordError.value.isEmpty
                          ? null
                          : controller.confirmPasswordError.value,
                  onChanged:
                      controller.validateConfirmPassword,
                )),

            const SizedBox(height: 32),

            // -------- Create Account Button --------
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isSignUpEnabled.value &&
                            !authController.isLoading.value
                        ? () => controller.signUp()
                        : null,
                    child: authController.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                      AppColors.textWhite),
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

            // -------- General Error --------
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
