import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../theme/light_theme.dart';
import '../theme/dark_theme.dart';

class ThemeController extends GetxController {
  final GetStorage _storage = GetStorage();
  final String _themeKey = 'isDarkMode';
  
  RxBool isDarkMode = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }
  
  void _loadTheme() {
    isDarkMode.value = _storage.read(_themeKey) ?? false;
    _updateTheme();
  }
  
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _storage.write(_themeKey, isDarkMode.value);
    _updateTheme();
  }
  
  void _updateTheme() {
    Get.changeThemeMode(
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
    );
  }
  
  get currentTheme => isDarkMode.value ? DarkTheme.theme : LightTheme.theme;
}

