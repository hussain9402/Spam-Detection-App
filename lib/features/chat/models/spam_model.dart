import 'package:flutter/material.dart';

enum SpamRiskLevel {
  low,
  medium,
  high,
}

extension SpamRiskLevelExtension on SpamRiskLevel {
  String get label {
    switch (this) {
      case SpamRiskLevel.low:
        return 'LOW RISK';
      case SpamRiskLevel.medium:
        return 'MEDIUM RISK';
      case SpamRiskLevel.high:
        return 'HIGH RISK';
    }
  }

  Color get color {
    switch (this) {
      case SpamRiskLevel.low:
        return const Color(0xFFFFB800); // Yellow/Orange
      case SpamRiskLevel.medium:
        return const Color(0xFFFF6B6B); // Red-Orange
      case SpamRiskLevel.high:
        return const Color(0xFFFF3B30); // Red
    }
  }
}

/// One row on the main Spam tab: all spam in a single chat aggregated.
class SpamChatSummary {
  final String chatId;
  final String displayTitle;
  final String? subtitlePhone;
  final int spamMessageCount;
  final String lastPreview;
  final DateTime lastSpamAt;

  const SpamChatSummary({
    required this.chatId,
    required this.displayTitle,
    this.subtitlePhone,
    required this.spamMessageCount,
    required this.lastPreview,
    required this.lastSpamAt,
  });
}

class SpamMessage {
  final String id;
  /// For Firestore `chats/{chatId}/messages/{messageId}` updates (soft delete, etc.)
  final String chatId;
  final String messageId;
  final String senderName;
  final String senderPhone;
  final String? senderImage;
  final String category; // Unknown Number, Promotional, Spam Bot, etc.
  final String messageContent;
  final DateTime receivedTime;
  final SpamRiskLevel riskLevel;
  final int blockedCount;

  SpamMessage({
    required this.id,
    required this.chatId,
    required this.messageId,
    required this.senderName,
    required this.senderPhone,
    this.senderImage,
    required this.category,
    required this.messageContent,
    required this.receivedTime,
    required this.riskLevel,
    this.blockedCount = 0,
  });
}
