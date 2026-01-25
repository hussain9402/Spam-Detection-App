import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spamdetection/core/constants/app_assets.dart';
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
  
// inside _SplashScreenState

void _checkAuthAndNavigate() {
  Future.delayed(const Duration(seconds: 3), () async {
    final box = _authController.box;
    bool shouldRemember = box.read('remember_me') ?? false;
    var firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null && shouldRemember) {
      // 5. User is logged in AND wants to be remembered
      Get.offAllNamed(AppRoutes.mainNavigation);
    } else if (firebaseUser != null && !shouldRemember) {
      // 6. User is logged in BUT "Remember Me" was false: Logout now
      await _authController.logout(); 
      _authController.navigateToOnboarding();
    } else {
      // No session
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
              AppAssets.splashlogo,
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
