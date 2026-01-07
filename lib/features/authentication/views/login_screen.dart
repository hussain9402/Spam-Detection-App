import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
// import '../widgets/social_login_button.dart'; // COMMENTED OUT - social login disabled
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
                        'Log in',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: ' to Chatbox'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Welcome message
            Text(
              AppStrings.loginWelcome,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGray,
                height: 1.5,
              ),
            ),
            // Social Login Buttons - COMMENTED OUT (keeping only email/password)
            // const SizedBox(height: 32),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     SocialLoginButton(
            //       provider: SocialProvider.facebook,
            //       onPressed: () => controller.socialLogin('facebook'),
            //     ),
            //     const SizedBox(width: 16),
            //     SocialLoginButton(
            //       provider: SocialProvider.google,
            //       onPressed: () => controller.socialLogin('google'),
            //     ),
            //     const SizedBox(width: 16),
            //     SocialLoginButton(
            //       provider: SocialProvider.apple,
            //       onPressed: () => controller.socialLogin('apple'),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 32),
            // // OR Separator
            // Row(
            //   children: [
            //     Expanded(
            //       child: Divider(
            //         color: AppColors.borderGray,
            //         thickness: 1,
            //       ),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.symmetric(horizontal: 16),
            //       child: Text(
            //         AppStrings.or,
            //         style: const TextStyle(
            //           color: AppColors.textGray,
            //           fontSize: 14,
            //         ),
            //       ),
            //     ),
            //     Expanded(
            //       child: Divider(
            //         color: AppColors.borderGray,
            //         thickness: 1,
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 32),
            // Email Field
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
            const SizedBox(height: 32),
            // Login Button
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoginEnabled.value && !authController.isLoading.value
                    ? () => controller.login()
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
                        AppStrings.loginButton,
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
            const SizedBox(height: 16),
            // Forgot Password Link
            Center(
              child: TextButton(
                onPressed: () => controller.navigateToForgotPassword(),
                child: const Text(
                  AppStrings.forgotPassword,
                  style: TextStyle(
                    color: AppColors.primaryTeal,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

