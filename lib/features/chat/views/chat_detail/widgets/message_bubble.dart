import 'package:flutter/material.dart';
import 'package:spamdetection/core/constants/app_colors.dart';
import 'package:spamdetection/features/chat/controllers/message_detail_controller.dart';
import 'package:spamdetection/features/chat/models/message_model.dart';


class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final MessageDetailController controller;

  const MessageBubble({
    super.key,
    required this.message,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isSent) {
      return _buildSentMessage(context);
    } else {
      return _buildReceivedMessage(context);
    }
  }

  Widget _buildSentMessage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.primaryTeal.withAlpha(50)
                      : AppColors.primaryTeal,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: message.type == MessageType.voice
                    ? _buildVoiceMessage()
                    : Text(
                        message.content,
                        style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
                      ),
              ),
            ),
          ],
        ),
        // const SizedBox(height: 4),
        Text(
          controller.formatTime(message.timestamp),
          style: const TextStyle(fontSize: 11, color: AppColors.textLightGray),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildReceivedMessage(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.yellow[700],
          child: const Icon(Icons.person, color: AppColors.textWhite, size: 20),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.senderName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.backgroundDarkSurface.withOpacity(0.5)
                      : AppColors.backgroundLightGray,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                controller.formatTime(message.timestamp),
                style: const TextStyle(fontSize: 11, color: AppColors.textLightGray),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceMessage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.play_arrow, color: AppColors.textWhite, size: 24),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            5,
            (index) => Container(
              width: 3,
              height: 12 + (index % 3) * 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: AppColors.textWhite,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '00:${message.voiceDuration.toString().padLeft(2, '0')}',
          style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
        ),
      ],
    );
  }
}