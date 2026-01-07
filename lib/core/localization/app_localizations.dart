import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
  
  static const List<Locale> supportedLocales = [
    Locale('en', ''),
  ];
  
  // Helper method to get localized string
  String _getLocalizedString(String key) {
    // For now, return the key. In production, this would load from ARB files
    // For Flutter's built-in localization, we'll use the generated code
    return key;
  }
  
  // Localized strings
  String get appName => _getLocalizedString('appName');
  String get splashAppName => _getLocalizedString('splashAppName');
  String get onboardingHeadline => _getLocalizedString('onboardingHeadline');
  String get onboardingDescription => _getLocalizedString('onboardingDescription');
  String get signUpWithMail => _getLocalizedString('signUpWithMail');
  String get existingAccount => _getLocalizedString('existingAccount');
  String get logIn => _getLocalizedString('logIn');
  String get loginTitle => _getLocalizedString('loginTitle');
  String get loginWelcome => _getLocalizedString('loginWelcome');
  String get yourEmail => _getLocalizedString('yourEmail');
  String get password => _getLocalizedString('password');
  String get loginButton => _getLocalizedString('loginButton');
  String get forgotPassword => _getLocalizedString('forgotPassword');
  String get signUpTitle => _getLocalizedString('signUpTitle');
  String get signUpDescription => _getLocalizedString('signUpDescription');
  String get yourName => _getLocalizedString('yourName');
  String get confirmPassword => _getLocalizedString('confirmPassword');
  String get createAccount => _getLocalizedString('createAccount');
  String get invalidEmail => _getLocalizedString('invalidEmail');
  String get or => _getLocalizedString('or');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['en'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

