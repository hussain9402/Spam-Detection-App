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
    Locale('ur', ''),
    Locale('zh', ''),
    Locale('es', ''),
    Locale('ar', ''),
    Locale('de', ''),
  ];
  
  // Helper method to get localized string
  String _getLocalizedString(String key) {
    // English strings
    final Map<String, String> _enStrings = {
      'appName': 'Spam Detection',
      'splashAppName': 'Spam Detection',
      'onboardingHeadline': 'Connect\nfriends\neasily &\nquickly',
      'onboardingDescription': 'Our chat app is the perfect way to stay\nconnected with friends and family.',
      'signUpWithMail': 'Sign up with mail',
      'existingAccount': 'Existing account? ',
      'logIn': 'Log in',
      'loginTitle': 'Log in to Chatbox',
      'loginWelcome': 'Welcome back! Sign in using your social account or email to continue us.',
      'yourEmail': 'Your email',
      'password': 'Password',
      'loginButton': 'Log in',
      'forgotPassword': 'Forgot password?',
      'signUpTitle': 'Sign up with Email',
      'signUpDescription': 'Get chatting with friends and family today by signing up for our chat app!',
      'yourName': 'Your name',
      'confirmPassword': 'Confirm Password',
      'createAccount': 'Create an account',
      'invalidEmail': 'Invalid email address',
      'or': 'OR',
      'home': 'Home',
      'calls': 'Calls',
      'contacts': 'Contacts',
      'settings': 'Settings',
      'message': 'Message',
      'recent': 'Recent',
      'myContact': 'My Contact',
      'activeNow': 'Active now',
      'today': 'Today',
      'writeYourMessage': 'Write your message',
      'displayName': 'Display Name',
      'emailAddress': 'Email Address',
      'address': 'Address',
      'phoneNumber': 'Phone Number',
      'mediaShared': 'Media Shared',
      'viewAll': 'View All',
      'account': 'Account',
      'accountSubtitle': 'Privacy, security, change number',
      'chat': 'Chat',
      'chatSubtitle': 'Chat history, theme, wallpapers',
      'notifications': 'Notifications',
      'notificationsSubtitle': 'Messages, group and others',
      'help': 'Help',
      'helpSubtitle': 'Help center, contact us, privacy policy',
      'appTheme': 'App Theme',
      'lightTheme': 'Light',
      'darkTheme': 'Dark',
      'systemTheme': 'System Default',
      'inviteAFriend': 'Invite a friend',
      'logout': 'Logout',
      'neverGiveUp': 'Never give up 💪',
      'appLanguage': 'App Language',
    };
    
    // Urdu strings
    final Map<String, String> _urStrings = {
      'appName': 'اسپیم کی تشخیص',
      'splashAppName': 'اسپیم کی تشخیص',
      'onboardingHeadline': 'دوستوں کو آسانی سے\nاور جلدی سے\nجوڑیں',
      'onboardingDescription': 'ہمارا چیٹ ایپ دوستوں اور خاندان سے جڑے رہنے کا بہترین طریقہ ہے۔',
      'signUpWithMail': 'ای میل کے ساتھ سائن اپ کریں',
      'existingAccount': 'پہلے سے موجود اکاؤنٹ؟ ',
      'logIn': 'لاگ ان',
      'loginTitle': 'چیٹ باکس میں لاگ ان کریں',
      'loginWelcome': 'خوش آمدید! اپنے سوشل اکاؤنٹ یا ای میل استعمال کرتے ہوئے سائن ان کریں۔',
      'yourEmail': 'آپ کا ای میل',
      'password': 'پاس ورڈ',
      'loginButton': 'لاگ ان',
      'forgotPassword': 'پاس ورڈ بھول گئے؟',
      'signUpTitle': 'ای میل کے ساتھ سائن اپ کریں',
      'signUpDescription': 'آج ہی اپنے دوستوں اور خاندان کے ساتھ چیٹنگ شروع کریں!',
      'yourName': 'آپ کا نام',
      'confirmPassword': 'پاس ورڈ کی تصدیق کریں',
      'createAccount': 'اکاؤنٹ بنائیں',
      'invalidEmail': 'غلط ای میل پتہ',
      'or': 'یا',
      'home': 'ہوم',
      'calls': 'کالز',
      'contacts': 'رابطے',
      'settings': 'ترتیبات',
      'message': 'پیغام',
      'recent': 'حالیہ',
      'myContact': 'میرے رابطے',
      'activeNow': 'ابھی آن لائن',
      'today': 'آج',
      'writeYourMessage': 'اپنا پیغام لکھیں',
      'displayName': 'نام',
      'emailAddress': 'ای میل پتہ',
      'address': 'پتہ',
      'phoneNumber': 'فون نمبر',
      'mediaShared': 'مشترکہ میڈیا',
      'viewAll': 'تمام دیکھیں',
      'account': 'اکاؤنٹ',
      'accountSubtitle': 'پرائیویسی، حفاظت، نمبر تبدیل کریں',
      'chat': 'چیٹ',
      'chatSubtitle': 'چیٹ ہسٹری، تھیم، وال پیپرز',
      'notifications': 'اطلاعات',
      'notificationsSubtitle': 'پیغامات، گروپ اور دیگر',
      'help': 'مدد',
      'helpSubtitle': 'ہیلپ سینٹر، رابطہ کریں، پرائیویسی پالیسی',
      'appTheme': 'ایپ کا تھیم',
      'lightTheme': 'ہلکا',
      'darkTheme': 'گہرا',
      'inviteAFriend': 'ایک دوست کو مدعو کریں',
      'logout': 'لاگ آؤٹ',
      'neverGiveUp': 'کبھی ہار نہیں مانیں 💪',
      'appLanguage': 'ایپ کی زبان',
    };
    
    // Select the appropriate language map
    Map<String, String> _localizedStrings = _enStrings; // Default to English
    
    switch (locale.languageCode) {
      case 'ur':
        _localizedStrings = _urStrings;
        break;
      case 'zh':
        _localizedStrings = _loadZhStrings();
        break;
      case 'es':
        _localizedStrings = _loadEsStrings();
        break;
      case 'ar':
        _localizedStrings = _loadArStrings();
        break;
      case 'de':
        _localizedStrings = _loadDeStrings();
        break;
      default:
        _localizedStrings = _enStrings;
    }
    
    return _localizedStrings[key] ?? key;
  }
  
  Map<String, String> _loadZhStrings() {
    return {
      'appName': '垃圾邮件检测',
      'splashAppName': '垃圾邮件检测',
      'onboardingHeadline': '轻松快速地\n连接\n朋友',
      'onboardingDescription': '我们的聊天应用是与朋友和家人保持联系的最佳方式。',
      'signUpWithMail': '使用邮箱注册',
      'existingAccount': '已有账户？ ',
      'logIn': '登录',
      'loginTitle': '登录聊天框',
      'loginWelcome': '欢迎回来！使用您的社交账户或邮箱登录以继续。',
      'yourEmail': '您的邮箱',
      'password': '密码',
      'loginButton': '登录',
      'forgotPassword': '忘记密码？',
      'signUpTitle': '使用邮箱注册',
      'signUpDescription': '立即注册我们的聊天应用，今天就开始与朋友和家人聊天！',
      'yourName': '您的姓名',
      'confirmPassword': '确认密码',
      'createAccount': '创建账户',
      'invalidEmail': '无效的邮箱地址',
      'or': '或',
      'home': '首页',
      'calls': '通话',
      'contacts': '联系人',
      'settings': '设置',
      'message': '消息',
      'recent': '最近',
      'myContact': '我的联系人',
      'activeNow': '现在在线',
      'today': '今天',
      'writeYourMessage': '输入您的消息',
      'displayName': '显示名称',
      'emailAddress': '邮箱地址',
      'address': '地址',
      'phoneNumber': '电话号码',
      'mediaShared': '共享的媒体',
      'viewAll': '查看全部',
      'account': '账户',
      'accountSubtitle': '隐私，安全，更改号码',
      'chat': '聊天',
      'chatSubtitle': '聊天历史，主题，壁纸',
      'notifications': '通知',
      'notificationsSubtitle': '消息，群组和其他',
      'help': '帮助',
      'helpSubtitle': '帮助中心，联系我们，隐私政策',
      'appTheme': '应用主题',
      'lightTheme': '浅色',
      'darkTheme': '深色',
      'systemTheme': '系统默认',
      'inviteAFriend': '邀请朋友',
      'logout': '退出登录',
      'neverGiveUp': '永不放弃 💪',
      'appLanguage': '应用语言',
    };
  }
  
  Map<String, String> _loadEsStrings() {
    return {
      'appName': 'Detección de Spam',
      'splashAppName': 'Detección de Spam',
      'onboardingHeadline': 'Conecta\namigos\nfácil y\nrápidamente',
      'onboardingDescription': 'Nuestra aplicación de chat es la forma perfecta de mantenerse conectado con amigos y familiares.',
      'signUpWithMail': 'Registrarse con correo',
      'existingAccount': '¿Ya tienes una cuenta? ',
      'logIn': 'Iniciar sesión',
      'loginTitle': 'Iniciar sesión en Chatbox',
      'loginWelcome': '¡Bienvenido de nuevo! Inicia sesión con tu cuenta social o correo electrónico para continuar.',
      'yourEmail': 'Tu correo electrónico',
      'password': 'Contraseña',
      'loginButton': 'Iniciar sesión',
      'forgotPassword': '¿Olvidaste tu contraseña?',
      'signUpTitle': 'Registrarse con correo electrónico',
      'signUpDescription': '¡Comienza a chatear con amigos y familiares hoy registrándote en nuestra aplicación de chat!',
      'yourName': 'Tu nombre',
      'confirmPassword': 'Confirmar contraseña',
      'createAccount': 'Crear una cuenta',
      'invalidEmail': 'Dirección de correo electrónico inválida',
      'or': 'O',
      'home': 'Inicio',
      'calls': 'Llamadas',
      'contacts': 'Contactos',
      'settings': 'Configuración',
      'message': 'Mensaje',
      'recent': 'Recientes',
      'myContact': 'Mis contactos',
      'activeNow': 'En línea ahora',
      'today': 'Hoy',
      'writeYourMessage': 'Escribe tu mensaje',
      'displayName': 'Nombre para mostrar',
      'emailAddress': 'Dirección de correo electrónico',
      'address': 'Dirección',
      'phoneNumber': 'Número de teléfono',
      'mediaShared': 'Medios compartidos',
      'viewAll': 'Ver todo',
      'account': 'Cuenta',
      'accountSubtitle': 'Privacidad, seguridad, cambiar número',
      'chat': 'Chat',
      'chatSubtitle': 'Historial de chat, tema, fondos de pantalla',
      'notifications': 'Notificaciones',
      'notificationsSubtitle': 'Mensajes, grupos y otros',
      'help': 'Ayuda',
      'helpSubtitle': 'Centro de ayuda, contáctanos, política de privacidad',
      'appTheme': 'Tema de la aplicación',
      'lightTheme': 'Claro',
      'darkTheme': 'Oscuro',
      'systemTheme': 'Predeterminado del sistema',
      'inviteAFriend': 'Invitar a un amigo',
      'logout': 'Cerrar sesión',
      'neverGiveUp': 'Nunca te rindas 💪',
      'appLanguage': 'Idioma de la aplicación',
    };
  }
  
  Map<String, String> _loadArStrings() {
    return {
      'appName': 'كشف الرسائل غير المرغوب فيها',
      'splashAppName': 'كشف الرسائل غير المرغوب فيها',
      'onboardingHeadline': 'تواصل مع\nالأصدقاء\nبسهولة\nوسرعة',
      'onboardingDescription': 'تطبيق الدردشة الخاص بنا هو الطريقة المثالية للبقاء على اتصال مع الأصدقاء والعائلة.',
      'signUpWithMail': 'سجل بالبريد الإلكتروني',
      'existingAccount': 'هل لديك حساب؟ ',
      'logIn': 'تسجيل الدخول',
      'loginTitle': 'تسجيل الدخول إلى صندوق الدردشة',
      'loginWelcome': 'مرحبًا بعودتك! سجل الدخول باستخدام حسابك الاجتماعي أو البريد الإلكتروني للمتابعة.',
      'yourEmail': 'بريدك الإلكتروني',
      'password': 'كلمة المرور',
      'loginButton': 'تسجيل الدخول',
      'forgotPassword': 'نسيت كلمة المرور؟',
      'signUpTitle': 'سجل بالبريد الإلكتروني',
      'signUpDescription': 'ابدأ الدردشة مع الأصدقاء والعائلة اليوم من خلال التسجيل في تطبيق الدردشة الخاص بنا!',
      'yourName': 'اسمك',
      'confirmPassword': 'تأكيد كلمة المرور',
      'createAccount': 'إنشاء حساب',
      'invalidEmail': 'عنوان بريد إلكتروني غير صالح',
      'or': 'أو',
      'home': 'الرئيسية',
      'calls': 'المكالمات',
      'contacts': 'جهات الاتصال',
      'settings': 'الإعدادات',
      'message': 'الرسالة',
      'recent': 'حديث',
      'myContact': 'جهات الاتصال الخاصة بي',
      'activeNow': 'نشط الآن',
      'today': 'اليوم',
      'writeYourMessage': 'اكتب رسالتك',
      'displayName': 'اسم العرض',
      'emailAddress': 'عنوان البريد الإلكتروني',
      'phoneNumber': 'رقم الهاتف',
      'address': 'العنوان',
      'mediaShared': 'الوسائط المشتركة',
      'viewAll': 'عرض الكل',
      'account': 'الحساب',
      'accountSubtitle': 'الخصوصية، الأمان، تغيير الرقم',
      'chat': 'الدردشة',
      'chatSubtitle': 'سجل الدردشة، المظهر، الخلفيات',
      'notifications': 'الإشعارات',
      'notificationsSubtitle': 'الرسائل، المجموعات وأخرى',
      'help': 'المساعدة',
      'helpSubtitle': 'مركز المساعدة، اتصل بنا، سياسة الخصوصية',
      'appTheme': 'مظهر التطبيق',
      'lightTheme': 'فاتح',
      'darkTheme': 'داكن',
      'systemTheme': 'افتراضي النظام',
      'inviteAFriend': 'دعوة صديق',
      'logout': 'تسجيل الخروج',
      'neverGiveUp': 'لا تستسلم أبدًا 💪',
      'appLanguage': 'لغة التطبيق',
    };
  }
  
  Map<String, String> _loadDeStrings() {
    return {
      'appName': 'Spam-Erkennung',
      'splashAppName': 'Spam-Erkennung',
      'onboardingHeadline': 'Verbinde\nFreunde\neinfach &\nschnell',
      'onboardingDescription': 'Unsere Chat-App ist die perfekte Möglichkeit, mit Freunden und Familie in Verbindung zu bleiben.',
      'signUpWithMail': 'Mit E-Mail registrieren',
      'existingAccount': 'Bereits ein Konto? ',
      'logIn': 'Anmelden',
      'loginTitle': 'Bei Chatbox anmelden',
      'loginWelcome': 'Willkommen zurück! Melden Sie sich mit Ihrem Social-Media-Konto oder Ihrer E-Mail an, um fortzufahren.',
      'yourEmail': 'Ihre E-Mail',
      'password': 'Passwort',
      'loginButton': 'Anmelden',
      'forgotPassword': 'Passwort vergessen?',
      'signUpTitle': 'Mit E-Mail registrieren',
      'signUpDescription': 'Beginnen Sie noch heute mit dem Chatten mit Freunden und Familie, indem Sie sich für unsere Chat-App registrieren!',
      'yourName': 'Ihr Name',
      'confirmPassword': 'Passwort bestätigen',
      'createAccount': 'Konto erstellen',
      'invalidEmail': 'Ungültige E-Mail-Adresse',
      'or': 'ODER',
      'home': 'Startseite',
      'calls': 'Anrufe',
      'contacts': 'Kontakte',
      'settings': 'Einstellungen',
      'message': 'Nachricht',
      'recent': 'Letzte',
      'myContact': 'Meine Kontakte',
      'activeNow': 'Jetzt aktiv',
      'today': 'Heute',
      'writeYourMessage': 'Schreiben Sie Ihre Nachricht',
      'displayName': 'Anzeigename',
      'emailAddress': 'E-Mail-Adresse',
      'address': 'Adresse',
      'phoneNumber': 'Telefonnummer',
      'mediaShared': 'Geteilte Medien',
      'viewAll': 'Alle anzeigen',
      'account': 'Konto',
      'accountSubtitle': 'Datenschutz, Sicherheit, Nummer ändern',
      'chat': 'Chat',
      'chatSubtitle': 'Chat-Verlauf, Theme, Hintergrundbilder',
      'notifications': 'Benachrichtigungen',
      'notificationsSubtitle': 'Nachrichten, Gruppen und andere',
      'help': 'Hilfe',
      'helpSubtitle': 'Hilfezentrum, Kontakt, Datenschutzerklärung',
      'appTheme': 'App-Design',
      'lightTheme': 'Hell',
      'darkTheme': 'Dunkel',
      'systemTheme': 'Systemstandard',
      'inviteAFriend': 'Einen Freund einladen',
      'logout': 'Abmelden',
      'neverGiveUp': 'Gib niemals auf 💪',
      'appLanguage': 'App-Sprache',
    };
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
  
  // Chat Screen Strings
  String get home => _getLocalizedString('home');
  String get calls => _getLocalizedString('calls');
  String get contacts => _getLocalizedString('contacts');
  String get settings => _getLocalizedString('settings');
  String get message => _getLocalizedString('message');
  String get recent => _getLocalizedString('recent');
  String get myContact => _getLocalizedString('myContact');
  String get activeNow => _getLocalizedString('activeNow');
  String get today => _getLocalizedString('today');
  String get writeYourMessage => _getLocalizedString('writeYourMessage');
  String get displayName => _getLocalizedString('displayName');
  String get emailAddress => _getLocalizedString('emailAddress');
  String get address => _getLocalizedString('address');
  String get phoneNumber => _getLocalizedString('phoneNumber');
  String get mediaShared => _getLocalizedString('mediaShared');
  String get viewAll => _getLocalizedString('viewAll');
  String get account => _getLocalizedString('account');
  String get accountSubtitle => _getLocalizedString('accountSubtitle');
  String get chat => _getLocalizedString('chat');
  String get chatSubtitle => _getLocalizedString('chatSubtitle');
  String get notifications => _getLocalizedString('notifications');
  String get notificationsSubtitle => _getLocalizedString('notificationsSubtitle');
  String get help => _getLocalizedString('help');
  String get helpSubtitle => _getLocalizedString('helpSubtitle');
  String get appTheme => _getLocalizedString('appTheme');
  String get lightTheme => _getLocalizedString('lightTheme');
  String get darkTheme => _getLocalizedString('darkTheme');
  String get systemTheme => _getLocalizedString('systemTheme');
  String get inviteAFriend => _getLocalizedString('inviteAFriend');
  String get logout => _getLocalizedString('logout');
  String get neverGiveUp => _getLocalizedString('neverGiveUp');
  String get appLanguage => _getLocalizedString('appLanguage');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['en', 'ur', 'zh', 'es', 'ar', 'de'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

