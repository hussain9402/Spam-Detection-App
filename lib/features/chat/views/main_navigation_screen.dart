import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:spamdetection/features/chat/views/contacts/contacts_screen.dart';
import '../controllers/navigation_controller.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'message/Home_screen.dart';
import 'spam/spam_protection_screen.dart';
import 'settings/settings_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navController = Get.put(NavigationController());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) {
          return;
        }
        if (navController.currentIndex.value !=
            NavigationController.messagesTabIndex) {
          navController.goToMessagesTab();
          return;
        }
        SystemNavigator.pop();
      },
      child: Scaffold(
        body: Obx(
          () => IndexedStack(
            index: navController.currentIndex.value,
            children: [
              const MessageScreen(),
              const SpamProtectionScreen(),
              // CallsScreen(),
              // UserProfileScreen(user: authController.currentUser.value!),
              ContactsScreen(),
              const SettingsScreen(),
            ],
          ),
        ),
        bottomNavigationBar: Obx(
          () => CustomBottomNavBar(
            currentIndex: navController.currentIndex.value,
            onTap: (index) => navController.changeTab(index),
          ),
        ),
      ),
    );
  }
}

