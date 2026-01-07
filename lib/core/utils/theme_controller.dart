import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../theme/light_theme.dart';
import '../theme/dark_theme.dart';

class ThemeController extends GetxController {
  final GetStorage _storage = GetStorage();
  final String _themeKey = 'themeMode'; // Changed to store theme mode string
  
  final RxString themeMode = 'system'.obs; // 'light', 'dark', 'system'
  
  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void _loadTheme() {
    themeMode.value = _storage.read(_themeKey) ?? 'system';
    _updateTheme();
  }

  void setThemeMode(String mode) {
    themeMode.value = mode;
    _storage.write(_themeKey, mode);
    _updateTheme();
  }

  void _updateTheme() {
    ThemeMode mode;
    switch (themeMode.value) {
      case 'light':
        mode = ThemeMode.light;
        break;
      case 'dark':
        mode = ThemeMode.dark;
        break;
      default:
        mode = ThemeMode.system;
    }
    Get.changeThemeMode(mode);
  }

  ThemeMode get currentThemeMode {
    switch (themeMode.value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
  
  bool get isDarkMode {
    if (themeMode.value == 'system') {
      // For system mode, we'll let the app handle it via ThemeMode.system
      // This getter is mainly for backward compatibility
      try {
        if (Get.context != null) {
          return MediaQuery.of(Get.context!).platformBrightness == Brightness.dark;
        }
      } catch (e) {
        // Fallback to false if context not available
      }
      return false;
    }
    return themeMode.value == 'dark';
  }
  
  get currentTheme => isDarkMode ? DarkTheme.theme : LightTheme.theme;
  
  String getCurrentThemeName(String lightThemeName, String darkThemeName, String systemThemeName) {
    switch (themeMode.value) {
      case 'light':
        return lightThemeName;
      case 'dark':
        return darkThemeName;
      default:
        return systemThemeName;
    }
  }
}

