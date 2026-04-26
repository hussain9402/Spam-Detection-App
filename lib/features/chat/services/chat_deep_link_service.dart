import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:spamdetection/core/utils/contact_display_name.dart';
import 'package:spamdetection/features/authentication/controllers/auth_controller.dart';
import 'package:spamdetection/features/chat/controllers/navigation_controller.dart';
import 'package:spamdetection/features/chat/models/chat_model.dart';
import 'package:spamdetection/core/routes/app_routes.dart';
import 'package:spamdetection/features/chat/views/chat_detail/chat_detail_screen.dart';

/// Handles `spamdetection://chat?phone=...` so scanning a profile QR opens a 1:1 chat.
class ChatDeepLinkService extends GetxService {
  static const String pendingPhoneStorageKey = 'pending_qr_chat_phone';

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  /// URI string encoded in the settings QR (other user opens this in the app).
  static String buildChatUriString(String phone) {
    final String p = phone.trim();
    return Uri(
      scheme: 'spamdetection',
      host: 'chat',
      queryParameters: <String, String>{'phone': p},
    ).toString();
  }

  @override
  void onInit() {
    super.onInit();
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (_) {},
    );
    unawaited(_readInitialLink());
  }

  Future<void> _readInitialLink() async {
    try {
      final Uri? initial = await _appLinks.getInitialLink();
      if (initial != null) {
        _handleUri(initial);
      }
    } catch (_) {
      // No initial link or unsupported platform
    }
  }

  void _handleUri(Uri uri) {
    if (uri.scheme != 'spamdetection') {
      return;
    }
    if (uri.host != 'chat') {
      return;
    }
    final String? phone = uri.queryParameters['phone']?.trim();
    if (phone == null || phone.isEmpty) {
      return;
    }
    openChatWithOtherPhone(phone);
  }

  /// Parses text from an in-app QR scan ([QrScanScreen]) or clipboard paste.
  void handleScannedQrPayload(String raw) {
    final String t = raw.trim();
    if (t.isEmpty) {
      return;
    }

    if (t.toLowerCase().startsWith('tel:')) {
      openChatWithOtherPhone(t.substring(4).trim());
      return;
    }

    final Uri? asUri = Uri.tryParse(t);
    if (asUri != null &&
        asUri.scheme == 'spamdetection' &&
        asUri.host == 'chat') {
      _handleUri(asUri);
      return;
    }

    final String compact = t.replaceAll(RegExp(r'[\s\-]'), '');
    if (RegExp(r'^\+?\d{7,15}$').hasMatch(compact)) {
      openChatWithOtherPhone(compact);
      return;
    }

    Get.snackbar(
      'QR',
      'Could not read a chat link or phone number from this code.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Call after [MainNavigationScreen] is ready or when auth finishes loading profile.
  void consumePendingPhoneIfAny() {
    final GetStorage box = GetStorage();
    final Object? raw = box.read(pendingPhoneStorageKey);
    final String pending = raw == null ? '' : raw.toString().trim();
    if (pending.isEmpty) {
      return;
    }
    if (!_hasMyPhone()) {
      return;
    }
    box.remove(pendingPhoneStorageKey);
    openChatWithOtherPhone(pending);
  }

  bool _hasMyPhone() {
    if (!Get.isRegistered<AuthController>()) {
      return false;
    }
    final AuthController auth = Get.find<AuthController>();
    final String fromUser = (auth.currentUser.value?.phoneNumber ?? '').trim();
    if (fromUser.isNotEmpty) {
      return true;
    }
    return auth.cachedPhoneNumber.trim().isNotEmpty;
  }

  void openChatWithOtherPhone(String otherPhoneRaw) {
    final String otherPhone = otherPhoneRaw.trim();
    if (otherPhone.isEmpty) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openChatWithOtherPhoneSync(otherPhone);
    });
  }

  void _openChatWithOtherPhoneSync(String otherPhone) {
    if (!Get.isRegistered<AuthController>()) {
      GetStorage().write(pendingPhoneStorageKey, otherPhone);
      return;
    }
    final AuthController auth = Get.find<AuthController>();
    final String myPhone = (auth.currentUser.value?.phoneNumber ?? '')
            .trim()
            .isEmpty
        ? auth.cachedPhoneNumber.trim()
        : auth.currentUser.value!.phoneNumber.trim();

    if (myPhone.isEmpty) {
      GetStorage().write(pendingPhoneStorageKey, otherPhone);
      return;
    }

    if (ContactDisplayName.phonesMatch(myPhone, otherPhone)) {
      Get.snackbar(
        'Chat',
        'You cannot open a chat with yourself.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final List<String> numbers = <String>[myPhone, otherPhone]..sort();
    final String chatId = '${numbers[0]}_${numbers[1]}';

    final bool onMainShell = Get.isRegistered<NavigationController>();

    void pushChat() {
      if (Get.isRegistered<NavigationController>()) {
        Get.find<NavigationController>().goToMessagesTab();
      }
      final String displayName = ContactDisplayName.chatListTitle(
        otherPhone: otherPhone,
        fromFirestore: null,
      );
      final ChatModel chat = ChatModel(
        id: chatId,
        name: displayName,
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        phoneNumber: otherPhone,
        senderPhone: myPhone,
        unreadCount: 0,
      );
      Get.to(
        () => ChatDetailScreen(chat: chat),
        transition: Transition.rightToLeft,
      );
    }

    if (onMainShell) {
      pushChat();
      return;
    }

    Get.offAllNamed(AppRoutes.mainNavigation);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 350), () {
        if (Get.isRegistered<NavigationController>()) {
          Get.find<NavigationController>().goToMessagesTab();
        }
        pushChat();
      });
    });
  }

  @override
  void onClose() {
    _linkSubscription?.cancel();
    super.onClose();
  }
}
