import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spamdetection/features/authentication/controllers/auth_controller.dart';
import 'package:spamdetection/features/chat/views/contacts/contacts_screen.dart';
import 'package:spamdetection/features/chat/views/profile/user_profile_screen.dart';
import '../controllers/navigation_controller.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'message/Home_screen.dart';
import 'calls/calls_screen.dart';
import 'spam/spam_protection_screen.dart';
import 'settings/settings_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navController = Get.put(NavigationController());
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      body: Obx(() => IndexedStack(
        index: navController.currentIndex.value,
        children: [
          const MessageScreen(),
          const SpamProtectionScreen(),
          // CallsScreen(),
          // UserProfileScreen(user: authController.currentUser.value!),
          ContactsScreen(),
          const SettingsScreen(),
        ],
      )),
      bottomNavigationBar: Obx(() => CustomBottomNavBar(
        currentIndex: navController.currentIndex.value,
        onTap: (index) => navController.changeTab(index),
      )),
    );
  }
}

