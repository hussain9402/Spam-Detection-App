import 'package:cloud_firestore/cloud_firestore.dart'; // Import this to fix the errors
import 'package:get/get.dart';
import '../models/message_model.dart';
import '../models/chat_model.dart';
import '../../authentication/controllers/auth_controller.dart';

class MessageDetailController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Initialize Firestore
  final AuthController authController = Get.find<AuthController>();
  
  final Rx<ChatModel?> chat = Rx<ChatModel?>(null);
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isActive = true.obs; 
  final RxString messageText = ''.obs;

  void initializeWithChat(ChatModel chatModel) {
    chat.value = chatModel;
    listenToMessages(); // Start listening to real messages instead of dummy data
  }

  // Real-time listener for Firestore messages
 void listenToMessages() {
    if (chat.value == null) return;

    _firestore
        .collection('chats')
        .doc(chat.value!.id)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots(includeMetadataChanges: true) // <--- ADD THIS
        .listen((snapshot) {
      
      // Filter out metadata changes if they cause duplicates, or just map them
      final docs = snapshot.docs;
      
      messages.assignAll(docs.map((doc) {
        final data = doc.data();
        final String senderNumber = data['senderNumber'] ?? '';
        final String myNumber = authController.currentUser.value?.phoneNumber ?? '';

        // Handle the null timestamp during local cache phase
        DateTime msgTime;
        if (data['timestamp'] == null) {
          msgTime = DateTime.now(); // Temporary time until server responds
        } else {
          msgTime = (data['timestamp'] as Timestamp).toDate();
        }

        return MessageModel(
          id: doc.id,
          senderId: senderNumber,
          senderName: senderNumber == myNumber ? 'You' : (chat.value?.name ?? 'Other'),
          content: data['content'] ?? '',
          type: data['type'] == 'voice' ? MessageType.voice : MessageType.text,
          timestamp: msgTime,
          isSent: senderNumber == myNumber,
        );
      }).toList());
    });
  }
  Future<void> sendMessage() async {
    if (messageText.value.trim().isEmpty || chat.value == null) return;

    final String text = messageText.value.trim();
    final String chatId = chat.value!.id;
    final String myPhone = authController.currentUser.value?.phoneNumber ?? ''; // Get from Auth
    final String otherPhone = chat.value!.phoneNumber ?? '';

    try {
      // 1. Send the message to the subcollection
      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'senderNumber': myPhone,
        'content': text,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'text',
      });

      // 2. Update the main Chat document for the list view
      await _firestore.collection('chats').doc(chatId).set({
        'participants': [myPhone, otherPhone],
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'otherUserName': chat.value!.name,
      }, SetOptions(merge: true));

      messageText.value = '';
    } catch (e) {
      print("Error sending message: $e");
      Get.snackbar("Error", "Message failed to send: $e");
    }
  }

  String formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}