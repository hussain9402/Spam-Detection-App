class ChatModel {
  final String id;
  final String name;
  final String? profileImage;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isGroup;

  ChatModel({
    required this.id,
    required this.name,
    this.profileImage,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isGroup = false,
  });
}

