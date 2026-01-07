import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
// import '../widgets/social_login_button.dart'; // COMMENTED OUT - social login disabled
import '../controllers/auth_controller.dart';
// import '../../../core/routes/app_routes.dart'; // COMMENTED OUT - not used when social login is disabled

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // App Logo
                Image.asset(
                  'assets/icons/app_logo_full.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                // App Name
                Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 48),
                // Headline
                Text(
                  AppStrings.onboardingHeadline,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 24),
                // Description
                Text(
                  AppStrings.onboardingDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
                const Spacer(flex: 2),
                // Social Login Buttons - COMMENTED OUT (keeping only email/password)
                // Obx(() => Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     SocialLoginButton(
                //       provider: SocialProvider.facebook,
                //       onPressed: authController.isLoading.value
                //           ? null
                //           : () {
                //               authController.handleSocialLogin('facebook').then((success) {
                //                 if (success) {
                //                   Get.offAllNamed(AppRoutes.home);
                //                 } else {
                //                   Get.snackbar(
                //                     'Sign In Failed',
                //                     authController.errorMessage.value,
                //                     snackPosition: SnackPosition.BOTTOM,
                //                   );
                //                 }
                //               });
                //             },
                //     ),
                //     const SizedBox(width: 16),
                //     SocialLoginButton(
                //       provider: SocialProvider.google,
                //       onPressed: authController.isLoading.value
                //           ? null
                //           : () {
                //               authController.handleSocialLogin('google').then((success) {
                //                 if (success) {
                //                   Get.offAllNamed(AppRoutes.home);
                //                 } else {
                //                   Get.snackbar(
                //                     'Sign In Failed',
                //                     authController.errorMessage.value,
                //                     snackPosition: SnackPosition.BOTTOM,
                //                   );
                //                 }
                //               });
                //             },
                //     ),
                //     const SizedBox(width: 16),
                //     SocialLoginButton(
                //       provider: SocialProvider.apple,
                //       onPressed: authController.isLoading.value
                //           ? null
                //           : () {
                //               authController.handleSocialLogin('apple').then((success) {
                //                 if (success) {
                //                   Get.offAllNamed(AppRoutes.home);
                //                 } else {
                //                   Get.snackbar(
                //                     'Sign In Failed',
                //                     authController.errorMessage.value,
                //                     snackPosition: SnackPosition.BOTTOM,
                //                   );
                //                 }
                //               });
                //             },
                //     ),
                //   ],
                // )),
                // // Loading indicator
                // Obx(() => authController.isLoading.value
                //     ? const Padding(
                //         padding: EdgeInsets.only(top: 16),
                //         child: CircularProgressIndicator(
                //           valueColor: AlwaysStoppedAnimation<Color>(AppColors.textWhite),
                //         ),
                //       )
                //     : const SizedBox.shrink()),
                // const SizedBox(height: 32),
                // // OR Separator
                // Row(
                //   children: [
                //     Expanded(
                //       child: Divider(
                //         color: AppColors.textWhite.withOpacity(0.3),
                //         thickness: 1,
                //       ),
                //     ),
                //     Padding(
                //       padding: const EdgeInsets.symmetric(horizontal: 16),
                //       child: Text(
                //         AppStrings.or,
                //         style: TextStyle(
                //           color: AppColors.textWhite.withOpacity(0.9),
                //           fontSize: 14,
                //         ),
                //       ),
                //     ),
                //     Expanded(
                //       child: Divider(
                //         color: AppColors.textWhite.withOpacity(0.3),
                //         thickness: 1,
                //       ),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 24),
                // Sign up with mail button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => authController.navigateToSignup(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: AppColors.textWhite,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      AppStrings.signUpWithMail,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Existing account link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.existingAccount,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => authController.navigateToLogin(),
                      child: Text(
                        AppStrings.logIn,
                        style: TextStyle(
                          color: AppColors.primaryTeal,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
    );
  }
}

