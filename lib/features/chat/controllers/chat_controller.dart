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
    listenToMyChats();
  }

  void listenToMyChats() {
    // 1. Get your number from the AuthController
    final String? myNumber = Get.find<AuthController>().currentUser.value?.phoneNumber;

    if (myNumber == null || myNumber.isEmpty) {
      print("Error: No phone number found for current user.");
      return;
    }

    isLoading.value = true;

    // 2. Listen to the 'chats' collection where you are a participant
    _firestore
        .collection('chats')
        .where('participants', arrayContains: myNumber)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .listen((snapshot) {
      chats.value = snapshot.docs.map((doc) {
        final data = doc.data();
        
        // Find the other person's number
        List participants = data['participants'] ?? [];
        String otherPhone = participants.firstWhere(
          (phone) => phone != myNumber,
          orElse: () => "Unknown",
        );

        return ChatModel(
          id: doc.id,
          // Fallback to phone number if profile name isn't set yet
          name: data['otherUserName'] ?? otherPhone, 
          lastMessage: data['lastMessage'] ?? '',
          lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
          phoneNumber: otherPhone,
          senderPhone: myNumber,
          unreadCount: data['unreadCount'] ?? 0,
        );
      }).toList();
      
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