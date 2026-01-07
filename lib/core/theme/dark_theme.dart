import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class DarkTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryTeal,
      scaffoldBackgroundColor: AppColors.backgroundDark, // #121212
      // Set status bar style to light icons (white)
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light, // Light icons (white)
          statusBarBrightness: Brightness.dark, // For iOS
        ),
      ),
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryTeal,
        secondary: AppColors.primaryTeal,
        error: AppColors.errorRed,
        surface: AppColors.backgroundDarkSurface, // #1E1E1E for surfaces
        onPrimary: AppColors.textWhite,
        onSecondary: AppColors.textWhite,
        onError: AppColors.textWhite,
        onSurface: AppColors.textWhite, // Keep white for text on dark surfaces
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textWhite,
          fontStyle: FontStyle.normal,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textWhite,
          fontStyle: FontStyle.normal,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textWhite,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textWhite,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textWhite,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.textGray,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryTeal,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(
          color: AppColors.primaryTeal,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryTeal, width: 2),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.errorRed),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.errorRed, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryTeal,
          foregroundColor: AppColors.textWhite,
          disabledBackgroundColor: AppColors.buttonDisabled,
          disabledForegroundColor: AppColors.buttonDisabledText,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryTeal,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.backgroundDarkSurface, // #1E1E1E
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textWhite,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 16,
          color: AppColors.textWhite,
        ),
      ),
    );
  }
}

