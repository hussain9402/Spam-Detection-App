import 'package:get/get.dart';
import '../models/message_model.dart';
import '../models/chat_model.dart';
import '../../authentication/controllers/auth_controller.dart';

class MessageDetailController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final Rx<ChatModel?> chat = Rx<ChatModel?>(null);
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isActive = true.obs; // For "Active now" status
  final RxString messageText = ''.obs;

  void initializeWithChat(ChatModel chatModel) {
    chat.value = chatModel;
    _loadMessages();
  }

  void _loadMessages() {
    // Dummy messages matching the design
    messages.value = [
      MessageModel(
        id: '1',
        senderId: 'other',
        senderName: chat.value?.name ?? 'Jhon Abraham',
        content: 'Hello ! Nazrul How are you?',
        type: MessageType.text,
        timestamp: DateTime.now().copyWith(hour: 9, minute: 25),
        isSent: false,
      ),
      MessageModel(
        id: '2',
        senderId: 'me',
        senderName: authController.currentUser.value?.name ?? 'You',
        content: 'Hello! Jhon abraham',
        type: MessageType.text,
        timestamp: DateTime.now().copyWith(hour: 9, minute: 25),
        isSent: true,
      ),
      MessageModel(
        id: '3',
        senderId: 'other',
        senderName: chat.value?.name ?? 'Jhon Abraham',
        content: 'Have a great working week!!',
        type: MessageType.text,
        timestamp: DateTime.now().copyWith(hour: 9, minute: 25),
        isSent: false,
      ),
      MessageModel(
        id: '4',
        senderId: 'me',
        senderName: authController.currentUser.value?.name ?? 'You',
        content: 'You did your job well!',
        type: MessageType.text,
        timestamp: DateTime.now().copyWith(hour: 9, minute: 25),
        isSent: true,
      ),
      MessageModel(
        id: '5',
        senderId: 'other',
        senderName: chat.value?.name ?? 'Jhon Abraham',
        content: 'Hope you like it',
        type: MessageType.text,
        timestamp: DateTime.now().copyWith(hour: 9, minute: 25),
        isSent: false,
      ),
      MessageModel(
        id: '6',
        senderId: 'me',
        senderName: authController.currentUser.value?.name ?? 'You',
        content: '', // Voice message
        type: MessageType.voice,
        timestamp: DateTime.now().copyWith(hour: 9, minute: 25),
        isSent: true,
        voiceDuration: 16,
      ),
    ];
  }

  void sendMessage() {
    if (messageText.value.trim().isEmpty) return;

    final newMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: authController.currentUser.value?.id ?? 'me',
      senderName: authController.currentUser.value?.name ?? 'You',
      content: messageText.value.trim(),
      type: MessageType.text,
      timestamp: DateTime.now(),
      isSent: true,
    );

    messages.add(newMessage);
    messageText.value = '';
  }

  String formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

