import 'package:get/get.dart';
import '../models/chat_model.dart';
import '../models/status_model.dart';

class ChatController extends GetxController {
  final RxList<ChatModel> chats = <ChatModel>[].obs;
  final RxList<StatusModel> statuses = <StatusModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
  }

  void _loadDummyData() {
    // Dummy chats
    chats.value = [
      ChatModel(
        id: '1',
        name: 'Alex Linderson',
        lastMessage: 'How are you today?',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 2)),
        unreadCount: 3,
      ),
      ChatModel(
        id: '2',
        name: 'Team Align',
        lastMessage: 'Don\'t miss to attend the meeting.',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 2)),
        unreadCount: 4,
        isGroup: true,
      ),
      ChatModel(
        id: '3',
        name: 'John Ahraham',
        lastMessage: 'Hey! Can you join the meeting?',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      ChatModel(
        id: '4',
        name: 'Sabila Sayma',
        lastMessage: 'How are you today?',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      ChatModel(
        id: '5',
        name: 'John Borino',
        lastMessage: 'Have a good day 🌸',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    ];

    // Dummy statuses
    statuses.value = [
      StatusModel(
        id: 'my_status',
        name: 'My status',
        isMyStatus: true,
      ),
      StatusModel(
        id: 'adil',
        name: 'Adil',
      ),
      StatusModel(
        id: 'marina',
        name: 'Marina',
      ),
      StatusModel(
        id: 'dean',
        name: 'Dean',
      ),
      StatusModel(
        id: 'max',
        name: 'Max',
      ),
    ];
  }

  String _getTimeAgo(DateTime dateTime) {
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

  String getTimeAgo(DateTime dateTime) => _getTimeAgo(dateTime);
}

