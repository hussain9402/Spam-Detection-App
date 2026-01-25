import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:spamdetection/features/authentication/controllers/auth_controller.dart';
import '../models/chat_model.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<ChatModel> chats = <ChatModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    // 1. Try to load immediately if user is already available
    listenToMyChats();

    // 2. Also re-trigger if the current user changes (e.g., after login or splash fetch)
    ever(Get.find<AuthController>().currentUser, (user) {
      print("DEBUG: currentUser changed: ${user?.phoneNumber}");
      if (user != null && user.phoneNumber.isNotEmpty) {
        listenToMyChats();
      }
    });
  }

  void listenToMyChats() {
    // 1. Get your number from the AuthController
    final String? myNumber = Get.find<AuthController>().currentUser.value?.phoneNumber;

    print("DEBUG: listenToMyChats called. myNumber: '$myNumber'");

    if (myNumber == null || myNumber.isEmpty) {
      // Don't print error yet, just wait for the 'ever' listener to trigger
      return;
    }

    isLoading.value = true;

    // 2. Listen to the 'chats' collection where you are a participant
    _firestore
        .collection('chats')
        .where('participants', arrayContains: myNumber)
        .snapshots()
        .listen((snapshot) {
      print("DEBUG: Received snapshot with ${snapshot.docs.length} chats");
      
      final List<ChatModel> fetchedChats = snapshot.docs.map((doc) {
        final data = doc.data();
        
        // Find the other person's number
        List participants = data['participants'] ?? [];
        String otherPhone = participants.firstWhere(
          (phone) => phone != myNumber,
          orElse: () => "Unknown",
        );

        final lastMsg = data['lastMessage'] ?? '';
        print("DEBUG: Chat ${doc.id} lastMessage: '$lastMsg'");

        return ChatModel(
          id: doc.id,
          // Fallback to phone number if profile name isn't set yet
          name: data['otherUserName'] ?? otherPhone, 
          lastMessage: lastMsg,
          lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
          phoneNumber: otherPhone,
          senderPhone: myNumber,
          unreadCount: data['unreadCount'] ?? 0,
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