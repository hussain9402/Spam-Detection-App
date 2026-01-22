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

class SpamMessage {
  final String id;
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
