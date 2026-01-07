enum MessageType {
  text,
  voice,
  image,
}

class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderPhotoUrl;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isSent; // true if sent by current user, false if received
  final int? voiceDuration; // in seconds, for voice messages

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.isSent,
    this.voiceDuration,
  });
}

