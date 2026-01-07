import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/localization/app_localizations.dart';
import '../controllers/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthController _authController = Get.put(AuthController());
  
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }
  
  void _checkAuthAndNavigate() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_authController.isAuthenticated.value) {
        Get.offNamed(AppRoutes.mainNavigation);
      } else {
        _authController.navigateToOnboarding();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Image.asset(
              'assets/icons/app_logo-preview.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            // App Name
            Text(
              localizations.splashAppName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

