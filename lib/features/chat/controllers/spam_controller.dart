import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../authentication/controllers/auth_controller.dart';
import '../../authentication/models/user_model.dart';
import '../../../shared/services/contacts_service.dart';
import 'chat_controller.dart';
import '../models/chat_model.dart';
import '../models/spam_model.dart';

/// Firestore chat fields used to mirror the main chat list (`otherUserName` / other party).
class _ChatInfo {
  const _ChatInfo({
    required this.otherUserName,
    required this.otherPhone,
    required this.participants,
  });

  final String otherUserName;
  final String otherPhone;
  final List<String> participants;
}

class SpamController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<SpamMessage> spamMessages = <SpamMessage>[].obs;
  /// One entry per chat that has spam (main Spam tab list).
  final RxList<SpamChatSummary> spamChats = <SpamChatSummary>[].obs;
  final RxInt blockedCount = 0.obs;

  /// Latest raw Firestore payload per message (to rebuild when contacts load).
  final Map<String, Map<String, Map<String, dynamic>>> _rawByChatAndMessageId = {};
  final Map<String, _ChatInfo> _chatInfoById = {};
  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
      _messageSubscriptions = {};
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _chatsSubscription;

  /// Avoid re-creating all listeners on every [AuthController.currentUser] refresh (fixes flicker / wrong data when returning to this tab).
  String? _lastBoundPhone;
  Timer? _rebindDebounce;
  Timer? _highlightClearTimer;

  /// Same id format as [SpamMessage.id]: `"${chatId}_$messageId"`.
  final Rx<String?> highlightedSpamMessageId = Rx<String?>(null);

  /// Highlight scroll target on the main Spam tab (one row per chat).
  final GlobalKey spamChatRowHighlightKey = GlobalKey();

  /// Highlight scroll target on the per-chat spam thread.
  final GlobalKey spamMessageHighlightKey = GlobalKey();

  @override
  void onInit() {
    super.onInit();
    _lastBoundPhone = _myParticipantPhone();
    if (!Get.isRegistered<ContactsController>()) {
      Get.put(ContactsController(), permanent: true);
    }
    _rebindSpamListeners();

    final AuthController auth = Get.find<AuthController>();
    ever<UserModel?>(
      auth.currentUser,
      (UserModel? _) {
        final String? p = _myParticipantPhone();
        if (p == _lastBoundPhone) {
          if (p != null) {
            _rebuildSpamList();
          }
          return;
        }
        _lastBoundPhone = p;
        _rebindSpamListeners();
      },
    );

    final ContactsController cc = Get.find<ContactsController>();
    ever<bool>(
      cc.isLoading,
      (bool busy) {
        if (!busy) {
          _rebuildSpamList();
        }
      },
    );
    ever<List<ContactModel>>(
      cc.contacts,
      (List<ContactModel> _) => _rebuildSpamList(),
    );
  }

  @override
  void onReady() {
    super.onReady();
    if (!Get.isRegistered<ChatController>()) {
      Get.put(ChatController());
    }
    ever<List<ChatModel>>(
      Get.find<ChatController>().chats,
      (List<ChatModel> _) {
        _syncMessageListenersWithHomeChats();
        _rebuildSpamList();
      },
    );
    unawaited(
      Get.find<ContactsController>().loadContacts().then(
            (_) => _rebuildSpamList(),
          ),
    );
    Future<void>.microtask(_syncMessageListenersWithHomeChats);
    ever<List<SpamMessage>>(spamMessages, (_) => _tryScrollToHighlight());
    ever<List<SpamChatSummary>>(spamChats, (_) => _tryScrollToHighlight());
  }

  List<SpamMessage> spamMessagesForChat(String chatId) {
    final List<SpamMessage> list = spamMessages
        .where((SpamMessage m) => m.chatId == chatId)
        .toList();
    list.sort((SpamMessage a, SpamMessage b) =>
        b.receivedTime.compareTo(a.receivedTime));
    return list;
  }

  /// After opening the Spam tab from a chat, scroll to and emphasize this item.
  void setHighlightedMessageFromChat(String chatId, String messageId) {
    if (chatId.isEmpty || messageId.isEmpty) {
      return;
    }
    final String id = '${chatId}_$messageId';
    highlightedSpamMessageId.value = id;
    _highlightClearTimer?.cancel();
    _highlightClearTimer = Timer(const Duration(seconds: 8), () {
      if (highlightedSpamMessageId.value == id) {
        highlightedSpamMessageId.value = null;
      }
    });
    _tryScrollToHighlight();
  }

  /// Call after opening the per-chat spam thread so a highlighted message scrolls into view.
  void scheduleScrollToSpamHighlight() {
    _tryScrollToHighlight();
  }

  void _tryScrollToHighlight() {
    final String? id = highlightedSpamMessageId.value;
    if (id == null || id.isEmpty) {
      return;
    }
    String? chatId;
    for (final SpamMessage m in spamMessages) {
      if (m.id == id) {
        chatId = m.chatId;
        break;
      }
    }
    if (chatId == null || !spamChats.any((SpamChatSummary s) => s.chatId == chatId)) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (highlightedSpamMessageId.value != id) {
        return;
      }
      final BuildContext? ctx = spamMessageHighlightKey.currentContext ??
          spamChatRowHighlightKey.currentContext;
      if (ctx != null && ctx.mounted) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          alignment: 0.12,
        );
      }
    });
  }

  @override
  void onClose() {
    _highlightClearTimer?.cancel();
    _highlightClearTimer = null;
    _rebindDebounce?.cancel();
    _rebindDebounce = null;
    _chatsSubscription?.cancel();
    for (final sub in _messageSubscriptions.values) {
      sub.cancel();
    }
    _messageSubscriptions.clear();
    super.onClose();
  }

  /// Re-attach Firestore listeners (e.g. after a transient error or pull-to-refresh).
  void refreshSpamInbox() {
    _rebindSpamListeners();
  }

  String? _myParticipantPhone() {
    final AuthController auth = Get.find<AuthController>();
    final String fromUser = (auth.currentUser.value?.phoneNumber ?? '').trim();
    if (fromUser.isNotEmpty) return fromUser;
    final String fromCache = auth.cachedPhoneNumber.trim();
    if (fromCache.isNotEmpty) return fromCache;
    return null;
  }

  void _rebindSpamListeners() {
    _chatsSubscription?.cancel();
    _chatsSubscription = null;
    for (final sub in _messageSubscriptions.values) {
      sub.cancel();
    }
    _messageSubscriptions.clear();
    _rawByChatAndMessageId.clear();
    _chatInfoById.clear();

    final String? myPhone = _myParticipantPhone();
    if (myPhone == null || myPhone.isEmpty) {
      _rebuildSpamList();
      return;
    }

    _chatsSubscription = _firestore
        .collection('chats')
        .where('participants', arrayContains: myPhone)
        .snapshots()
        .listen(
          (snap) => _onChatsSnapshot(snap, myPhone),
          onError: (Object e, StackTrace s) {
            _scheduleRebind();
          },
        );
    unawaited(Future<void>.microtask(_syncMessageListenersWithHomeChats));
  }

  void _scheduleRebind() {
    if (isClosed) {
      return;
    }
    _rebindDebounce?.cancel();
    _rebindDebounce = Timer(const Duration(seconds: 2), () {
      if (isClosed) {
        return;
      }
      _rebindDebounce = null;
      _rebindSpamListeners();
    });
  }

  /// Ensures we listen to `chats/{id}/messages` for every room already on the home list.
  /// This fixes intermittent empty state when the `arrayContains: myPhone` query does
  /// not match stored `participants` formatting (e.g. +92 vs 0) or loads after [ChatController].
  void _syncMessageListenersWithHomeChats() {
    if (!Get.isRegistered<ChatController>()) {
      return;
    }
    final String? me = _myParticipantPhone();
    if (me == null || me.isEmpty) {
      return;
    }
    for (final ChatModel chat in Get.find<ChatController>().chats) {
      final String other = (chat.phoneNumber ?? '').trim();
      final String title =
          (chat.firestoreOtherName != null && chat.firestoreOtherName!.trim().isNotEmpty)
              ? chat.firestoreOtherName!.trim()
              : '';
      _chatInfoById[chat.id] = _ChatInfo(
        otherUserName: title,
        otherPhone: other,
        participants: <String>[
          me,
          if (other.isNotEmpty) other,
        ],
      );
      _attachSpamMessageListenerIfNeeded(chat.id);
    }
  }

  void _onChatsSnapshot(
    QuerySnapshot<Map<String, dynamic>> chatSnap,
    String myPhone,
  ) {
    final Set<String> activeChatIds = chatSnap.docs.map((d) => d.id).toSet();

    for (final String chatId in _messageSubscriptions.keys.toList()) {
      if (!activeChatIds.contains(chatId)) {
        _messageSubscriptions.remove(chatId)?.cancel();
        _rawByChatAndMessageId.remove(chatId);
        _chatInfoById.remove(chatId);
      }
    }

    for (final doc in chatSnap.docs) {
      final String chatId = doc.id;
      final Map<String, dynamic> d = doc.data();
      final List<String> participants = (d['participants'] is List)
          ? (d['participants'] as List)
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList()
          : <String>[];

      String otherPhone = '';
      for (final p in participants) {
        if (!_phonesMatch(p, myPhone)) {
          otherPhone = p;
          break;
        }
      }
      if (otherPhone.isEmpty && participants.length == 2) {
        otherPhone = _phonesMatch(participants[0], myPhone)
            ? participants[1]
            : participants[0];
      }

      _chatInfoById[chatId] = _ChatInfo(
        otherUserName: (d['otherUserName'] as String?)?.trim() ?? '',
        otherPhone: otherPhone,
        participants: participants,
      );

      _attachSpamMessageListenerIfNeeded(chatId);
    }

    _rebuildSpamList();
  }

  void _attachSpamMessageListenerIfNeeded(String chatId) {
    if (_messageSubscriptions.containsKey(chatId)) {
      return;
    }
    _messageSubscriptions[chatId] = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('spam_status', whereIn: const ['Spam', 'spam', 'SPAM'])
        .snapshots()
        .listen(
          (QuerySnapshot<Map<String, dynamic>> msgSnap) =>
              _onSpamMessagesSnapshot(chatId, msgSnap),
          onError: (Object e, StackTrace s) {
            _scheduleRebind();
          },
        );
  }

  void _onSpamMessagesSnapshot(
    String chatId,
    QuerySnapshot<Map<String, dynamic>> snap,
  ) {
    final Map<String, Map<String, dynamic>> forChat =
        _rawByChatAndMessageId.putIfAbsent(chatId, () => {});

    forChat.clear();
    for (final doc in snap.docs) {
      final Map<String, dynamic> data = doc.data();
      if (_isSoftDeletedFromSpam(data)) {
        continue;
      }
      if (!_isMarkedSpamStatus(data['spam_status'])) {
        continue;
      }
      forChat[doc.id] = Map<String, dynamic>.from(data);
    }
    _rebuildSpamList();
  }

  bool _isMarkedSpamStatus(dynamic raw) {
    if (raw == null) return false;
    if (raw is! String) return false;
    return raw.toLowerCase().trim() == 'spam';
  }

  /// User hid this from the spam inbox; the document stays in Firestore.
  bool _isSoftDeletedFromSpam(Map<String, dynamic> data) {
    final Object? v = data['deleted_from_spam'];
    if (v is bool) {
      return v;
    }
    if (v is int) {
      return v != 0;
    }
    return false;
  }

  String _messagePreviewForSpam(Map<String, dynamic> data) {
    final String type = (data['type'] as String?) ?? 'text';
    final String content = (data['content'] as String?) ?? '';
    final String? extracted = (data['extracted_text'] as String?)?.trim();

    if (extracted != null && extracted.isNotEmpty) {
      return extracted;
    }
    switch (type) {
      case 'image':
        return '📷 Image';
      case 'voice':
        return '🎤 Voice message';
      default:
        return content;
    }
  }

  String _resolveSenderDisplayName(String chatId, String senderNumber) {
    if (senderNumber.isEmpty) {
      return 'Unknown';
    }
    final String? my = _myParticipantPhone();
    if (my != null && _phonesMatch(senderNumber, my)) {
      final String name =
          (Get.find<AuthController>().currentUser.value?.name ?? '').trim();
      if (name.isNotEmpty) {
        return name;
      }
      return 'You';
    }

    // Same display name as the home chat list (otherUserName or phone) — most reliable.
    if (Get.isRegistered<ChatController>()) {
      for (final chat in Get.find<ChatController>().chats) {
        if (chat.id != chatId) {
          continue;
        }
        final String? other = chat.phoneNumber;
        if (other != null &&
            other.isNotEmpty &&
            _phonesMatch(senderNumber, other)) {
          final String n = chat.name.trim();
          if (n.isNotEmpty) {
            return n;
          }
        }
      }
    }

    final String? fromContact = _nameFromDeviceContacts(senderNumber);
    if (fromContact != null) {
      return fromContact;
    }

    final _ChatInfo? info = _chatInfoById[chatId];
    if (info != null && _phonesMatch(senderNumber, info.otherPhone)) {
      if (info.otherUserName.isNotEmpty) {
        return info.otherUserName;
      }
    }

    return senderNumber;
  }

  String? _nameFromDeviceContacts(String rawPhone) {
    if (!Get.isRegistered<ContactsController>()) {
      return null;
    }
    final ContactsController cc = Get.find<ContactsController>();
    for (final ContactModel cm in cc.contacts) {
      if (_phonesMatch(rawPhone, cm.phoneNumber)) {
        final String n = cm.contact.displayName.trim();
        if (n.isNotEmpty) {
          return n;
        }
      }
      for (final p in cm.contact.phones) {
        if (_phonesMatch(rawPhone, p.number)) {
          final String n = cm.contact.displayName.trim();
          if (n.isNotEmpty) {
            return n;
          }
        }
      }
    }
    return null;
  }

  static String _digitsOnly(String s) =>
      s.replaceAll(RegExp(r'[^\d]'), '');

  static String _normalizeToDigits(String phone) {
    var s = phone.trim();
    if (s.toLowerCase().startsWith('tel:')) {
      s = s.substring(4).trim();
    }
    return _digitsOnly(s);
  }

  static String _mobileTail(String digits) {
    if (digits.length <= 10) {
      return digits;
    }
    return digits.substring(digits.length - 10);
  }

  static bool _phonesMatch(String a, String b) {
    final String da = _normalizeToDigits(a);
    final String db = _normalizeToDigits(b);
    if (da.isEmpty || db.isEmpty) {
      return false;
    }
    if (da == db) {
      return true;
    }
    if (da.length >= 10 && db.length >= 10) {
      if (_mobileTail(da) == _mobileTail(db)) {
        return true;
      }
    }
    // e.g. 11-digit local vs 12-digit +country when last 10 already matched above or lengths differ
    final String long = da.length >= db.length ? da : db;
    final String short = da.length < db.length ? da : db;
    if (short.length >= 7 && long.length > short.length) {
      if (long.endsWith(short)) {
        return true;
      }
      if (long.length >= 10 && short.length >= 10) {
        if (long.endsWith(_mobileTail(short)) ||
            _mobileTail(long).endsWith(_mobileTail(short))) {
          return true;
        }
      }
    }
    return false;
  }

  SpamMessage _buildSpamMessage(
    String chatId,
    String messageId,
    Map<String, dynamic> data,
  ) {
    final String contentPreview = _messagePreviewForSpam(data);
    final String senderNumber = (data['senderNumber'] as String?)?.trim() ?? '';
    final Timestamp? ts = data['timestamp'] as Timestamp?;
    final DateTime receivedTime = ts?.toDate() ?? DateTime.now();
    final double confidence =
        (data['spam_confidence'] as num?)?.toDouble() ?? 0.0;

    final SpamRiskLevel riskLevel;
    if (confidence >= 0.8) {
      riskLevel = SpamRiskLevel.high;
    } else if (confidence >= 0.5) {
      riskLevel = SpamRiskLevel.medium;
    } else {
      riskLevel = SpamRiskLevel.low;
    }

    final String displayName =
        _resolveSenderDisplayName(chatId, senderNumber);
    final String statusLabel = (data['spam_status'] is String)
        ? (data['spam_status'] as String)
        : 'Spam';

    return SpamMessage(
      id: '${chatId}_$messageId',
      chatId: chatId,
      messageId: messageId,
      senderName: displayName,
      senderPhone: senderNumber.isNotEmpty ? senderNumber : '—',
      category: statusLabel,
      messageContent: contentPreview,
      receivedTime: receivedTime,
      riskLevel: riskLevel,
      blockedCount: 0,
    );
  }

  void _rebuildSpamList() {
    final List<SpamMessage> merged = <SpamMessage>[];
    for (final MapEntry<String, Map<String, Map<String, dynamic>>> chatEntry
        in _rawByChatAndMessageId.entries) {
      final String chatId = chatEntry.key;
      for (final MapEntry<String, Map<String, dynamic>> msgEntry
          in chatEntry.value.entries) {
        if (_isSoftDeletedFromSpam(msgEntry.value)) {
          continue;
        }
        if (!_isMarkedSpamStatus(msgEntry.value['spam_status'])) {
          continue;
        }
        merged.add(_buildSpamMessage(chatId, msgEntry.key, msgEntry.value));
      }
    }
    merged.sort(
      (a, b) => b.receivedTime.compareTo(a.receivedTime),
    );
    spamMessages.assignAll(merged);
    _rebuildSpamChatSummaries();
    _updateBlockedCount();
  }

  void _rebuildSpamChatSummaries() {
    final Map<String, List<SpamMessage>> byChat = <String, List<SpamMessage>>{};
    for (final SpamMessage m in spamMessages) {
      byChat.putIfAbsent(m.chatId, () => <SpamMessage>[]).add(m);
    }
    final List<SpamChatSummary> out = <SpamChatSummary>[];
    for (final MapEntry<String, List<SpamMessage>> e in byChat.entries) {
      final List<SpamMessage> msgs = List<SpamMessage>.from(e.value)
        ..sort((SpamMessage a, SpamMessage b) =>
            b.receivedTime.compareTo(a.receivedTime));
      if (msgs.isEmpty) {
        continue;
      }
      final SpamMessage latest = msgs.first;
      out.add(
        SpamChatSummary(
          chatId: e.key,
          displayTitle: _titleForSpamChatGroup(e.key, msgs),
          subtitlePhone: _subtitlePhoneForSpamChat(e.key, msgs),
          spamMessageCount: msgs.length,
          lastPreview: latest.messageContent,
          lastSpamAt: latest.receivedTime,
        ),
      );
    }
    out.sort(
      (SpamChatSummary a, SpamChatSummary b) =>
          b.lastSpamAt.compareTo(a.lastSpamAt),
    );
    spamChats.assignAll(out);
  }

  String _titleForSpamChatGroup(String chatId, List<SpamMessage> msgs) {
    if (Get.isRegistered<ChatController>()) {
      for (final ChatModel c in Get.find<ChatController>().chats) {
        if (c.id == chatId) {
          final String n = c.name.trim();
          if (n.isNotEmpty) {
            return n;
          }
        }
      }
    }
    final String? me = _myParticipantPhone();
    for (final SpamMessage m in msgs) {
      if (me != null &&
          m.senderPhone.isNotEmpty &&
          !_phonesMatch(m.senderPhone, me)) {
        final String n = m.senderName.trim();
        if (n.isNotEmpty) {
          return n;
        }
      }
    }
    return msgs.first.senderName;
  }

  String? _subtitlePhoneForSpamChat(String chatId, List<SpamMessage> msgs) {
    if (Get.isRegistered<ChatController>()) {
      for (final ChatModel c in Get.find<ChatController>().chats) {
        if (c.id == chatId) {
          final String? p = c.phoneNumber?.trim();
          if (p != null && p.isNotEmpty) {
            return p;
          }
        }
      }
    }
    final String? me = _myParticipantPhone();
    for (final SpamMessage m in msgs) {
      if (me != null &&
          m.senderPhone.isNotEmpty &&
          !_phonesMatch(m.senderPhone, me)) {
        return m.senderPhone;
      }
    }
    return null;
  }

  void _updateBlockedCount() {
    blockedCount.value = spamMessages.length;
  }

  /// Sets [deleted_from_spam] so the message no longer appears in the spam list or in the chat thread (document kept in Firestore).
  Future<void> softDeleteFromSpamInbox(String chatId, String messageId) async {
    final String composite = '${chatId}_$messageId';
    if (highlightedSpamMessageId.value == composite) {
      highlightedSpamMessageId.value = null;
      _highlightClearTimer?.cancel();
    }
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
            'deleted_from_spam': true,
            'deleted_from_spam_at': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      Get.snackbar('Could not update', e.toString());
    }
  }
}
