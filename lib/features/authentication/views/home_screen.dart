import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbox'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Obx(() => Center(
        child: authController.currentUser.value != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (authController.currentUser.value!.photoUrl != null)
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        authController.currentUser.value!.photoUrl!,
                      ),
                    )
                  else
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primaryTeal,
                      child: Text(
                        authController.currentUser.value!.name.isNotEmpty
                            ? authController.currentUser.value!.name[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 40,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome, ${authController.currentUser.value!.name}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    authController.currentUser.value!.email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textGray,
                    ),
                  ),
                ],

              )
            : const CircularProgressIndicator(),
            
      ) 
      ),
    );
  
  }
}



