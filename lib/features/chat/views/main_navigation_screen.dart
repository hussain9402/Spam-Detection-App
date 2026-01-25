import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

    return Scaffold(
      body: Obx(() => IndexedStack(
        index: navController.currentIndex.value,
        children: const [
          MessageScreen(),
          CallsScreen(),
          SpamProtectionScreen(),
          SettingsScreen(),
        ],
      )),
      bottomNavigationBar: Obx(() => CustomBottomNavBar(
        currentIndex: navController.currentIndex.value,
        onTap: (index) => navController.changeTab(index),
      )),
    );
  }
}

