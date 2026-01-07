import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  final GetStorage _storage = GetStorage();
  final String _languageKey = 'appLanguage';
  
  final Rx<Locale> currentLocale = const Locale('en', '').obs;

  @override
  void onInit() {
    super.onInit();
    _loadLanguage();
  }

  void _loadLanguage() {
    final savedLanguage = _storage.read(_languageKey);
    if (savedLanguage != null) {
      currentLocale.value = Locale(savedLanguage, '');
      Get.updateLocale(currentLocale.value);
    } else {
      currentLocale.value = const Locale('en', '');
    }
  }

  void changeLanguage(String languageCode) {
    currentLocale.value = Locale(languageCode, '');
    _storage.write(_languageKey, languageCode);
    Get.updateLocale(currentLocale.value);
  }

  String getCurrentLanguageName() {
    switch (currentLocale.value.languageCode) {
      case 'en':
        return 'English';
      case 'ur':
        return 'اردو (Urdu)';
      case 'zh':
        return '中文 (Mandarin Chinese)';
      case 'es':
        return 'Español (Spanish)';
      case 'ar':
        return 'العربية (Arabic)';
      case 'de':
        return 'Deutsch (German)';
      default:
        return 'English';
    }
  }
}

