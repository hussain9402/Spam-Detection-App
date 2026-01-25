enum MessageType {
  text,
  voice,
  image,
}

enum MessageStatus {
  sending,
  sent,
  failed,
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
  final MessageStatus status;
  final String? localPath; // For resending failed messages

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
    this.status = MessageStatus.sent,
    this.localPath,
  });

  MessageModel copyWith({
    String? id,
    MessageStatus? status,
    String? content,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId,
      senderName: senderName,
      senderPhotoUrl: senderPhotoUrl,
      content: content ?? this.content,
      type: type,
      timestamp: timestamp,
      isSent: isSent,
      voiceDuration: voiceDuration,
      status: status ?? this.status,
      localPath: localPath,
    );
  }
}

