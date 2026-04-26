import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:spamdetection/core/utils/contact_display_name.dart';
import 'package:spamdetection/features/authentication/controllers/auth_controller.dart';
import 'package:spamdetection/shared/services/contacts_service.dart';
import '../models/chat_model.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<ChatModel> chats = <ChatModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    if (!Get.isRegistered<ContactsController>()) {
      Get.put(ContactsController(), permanent: true);
    }
    final ContactsController cc = Get.find<ContactsController>();
    ever<bool>(
      cc.isLoading,
      (bool busy) {
        if (!busy) {
          _reapplyDisplayNamesFromContacts();
        }
      },
    );
    ever<List<ContactModel>>(
      cc.contacts,
      (List<ContactModel> _) => _reapplyDisplayNamesFromContacts(),
    );

    // 1. Try to load immediately if user is already available
    listenToMyChats();

    // 2. Also re-trigger if the current user changes (e.g. after login or splash fetch)
    ever(Get.find<AuthController>().currentUser, (user) {
      print("DEBUG: currentUser changed: ${user?.phoneNumber}");
      if (user != null &&
          (user.phoneNumber.isNotEmpty ||
              Get.find<AuthController>().cachedPhoneNumber.isNotEmpty)) {
        listenToMyChats();
      }
    });
  }

  void _reapplyDisplayNamesFromContacts() {
    if (chats.isEmpty) {
      return;
    }
    final List<ChatModel> next = <ChatModel>[];
    for (final ChatModel c in chats) {
      final String? p = c.phoneNumber;
      if (p == null || p.isEmpty) {
        next.add(c);
        continue;
      }
      final String title = ContactDisplayName.chatListTitle(
        otherPhone: p,
        fromFirestore: c.firestoreOtherName,
      );
      if (title == c.name) {
        next.add(c);
        continue;
      }
      next.add(
        ChatModel(
          id: c.id,
          name: title,
          lastMessage: c.lastMessage,
          lastMessageTime: c.lastMessageTime,
          phoneNumber: c.phoneNumber,
          senderPhone: c.senderPhone,
          unreadCount: c.unreadCount,
          isGroup: c.isGroup,
          firestoreOtherName: c.firestoreOtherName,
        ),
      );
    }
    chats.assignAll(next);
  }

  void listenToMyChats() {
    // 1. Get your number from the AuthController (match SpamController / sign-in flow)
    final AuthController auth = Get.find<AuthController>();
    String? myNumber = auth.currentUser.value?.phoneNumber;
    if (myNumber == null || myNumber.isEmpty) {
      final String cache = auth.cachedPhoneNumber.trim();
      if (cache.isNotEmpty) {
        myNumber = cache;
      }
    }

    print("DEBUG: listenToMyChats called. myNumber: '$myNumber'");

    if (myNumber == null || myNumber.isEmpty) {
      // Don't print error yet, just wait for the 'ever' listener to trigger
      return;
    }

    final String me = myNumber;

    isLoading.value = true;

    // 2. Listen to the 'chats' collection where you are a participant
    _firestore
        .collection('chats')
        .where('participants', arrayContains: me)
        .snapshots()
        .listen((snapshot) {
      print("DEBUG: Received snapshot with ${snapshot.docs.length} chats");
      
      final List<ChatModel> fetchedChats = snapshot.docs.map((doc) {
        final data = doc.data();
        
        // Find the other person\'s number (use digit-aware match, not string !=)
        final List<dynamic> participants = data['participants'] is List
            ? (data['participants'] as List<dynamic>)
            : <dynamic>[];
        String otherPhone = 'Unknown';
        for (final dynamic raw in participants) {
          final String s = raw.toString().trim();
          if (s.isEmpty) {
            continue;
          }
          if (!ContactDisplayName.phonesMatch(s, me)) {
            otherPhone = s;
            break;
          }
        }
        if (otherPhone == 'Unknown' && participants.length == 2) {
          otherPhone = ContactDisplayName.phonesMatch(
                participants[0].toString().trim(),
                me,
              )
              ? participants[1].toString().trim()
              : participants[0].toString().trim();
        }

        final String? firestoreName =
            (data['otherUserName'] as String?)?.trim().isNotEmpty == true
                ? (data['otherUserName'] as String?)
                : null;

        final lastMsg = data['lastMessage'] ?? '';
        print("DEBUG: Chat ${doc.id} lastMessage: '$lastMsg'");

        return ChatModel(
          id: doc.id,
          name: ContactDisplayName.chatListTitle(
            otherPhone: otherPhone,
            fromFirestore: firestoreName,
          ),
          lastMessage: lastMsg,
          lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate() ??
              DateTime.now(),
          phoneNumber: otherPhone,
          senderPhone: me,
          unreadCount: data['unreadCount'] ?? 0,
          firestoreOtherName: data['otherUserName'] as String?,
        );
      }).toList();

      // Sort manually since we removed orderBy from Firestore to avoid index requirement
      fetchedChats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      
      chats.value = fetchedChats;
      isLoading.value = false;
    }, onError: (error) {
      print("Firestore Error: $error");
      isLoading.value = false;
    });
  }

  // 3. The missing method to fix your MessageScreen error
  String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}