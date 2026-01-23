class ChatModel {
  final String id; // The unique room ID (e.g. phone1_phone2)
  final String name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String? phoneNumber; // The other person
  final String? senderPhone;  // You
  final int unreadCount;
  final bool isGroup;

  ChatModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
    this.phoneNumber,
    this.senderPhone,
    this.unreadCount = 0,
    this.isGroup = false,
  });
}