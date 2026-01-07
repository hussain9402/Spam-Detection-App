import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';
import 'core/utils/theme_controller.dart';
import 'core/localization/app_localizations.dart';
import 'core/routes/app_routes.dart';
import 'features/authentication/views/splash_screen.dart';
import 'features/authentication/views/onboarding_screen.dart';
import 'features/authentication/views/login_screen.dart';
import 'features/authentication/views/signup_screen.dart';
import 'features/authentication/views/home_screen.dart';
import 'features/authentication/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize GetStorage
  await GetStorage.init();
  
  // Initialize controllers
  Get.put(ThemeController());
  Get.put(AuthController());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    
    return GetMaterialApp(
      title: 'Chatbox',
      debugShowCheckedModeBanner: false,
      
      // Theme Configuration
      theme: LightTheme.theme,
      darkTheme: DarkTheme.theme,
      themeMode: themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
      
      // Localization Configuration
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en', ''),
      
      // Initial Route
      initialRoute: AppRoutes.splash,
      
      // Routes
      getPages: [
        GetPage(
          name: AppRoutes.splash,
          page: () => const SplashScreen(),
        ),
        GetPage(
          name: AppRoutes.onboarding,
          page: () => const OnboardingScreen(),
        ),
        GetPage(
          name: AppRoutes.login,
          page: () => const LoginScreen(),
        ),
        GetPage(
          name: AppRoutes.signup,
          page: () => const SignUpScreen(),
        ),
        GetPage(
          name: AppRoutes.home,
          page: () => const HomeScreen(),
        ),
      ],
    );
  }
}
