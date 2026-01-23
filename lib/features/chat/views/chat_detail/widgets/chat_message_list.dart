import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spamdetection/core/constants/app_colors.dart';
import 'package:spamdetection/features/chat/controllers/message_detail_controller.dart';
import 'package:spamdetection/features/chat/models/message_model.dart';
import 'package:spamdetection/features/chat/views/chat_detail/widgets/message_bubble.dart';


class ChatMessageList extends StatelessWidget {
  final MessageDetailController controller;

  const ChatMessageList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.messages.isEmpty) {
        return const Center(child: Text('No messages yet'));
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        itemCount: controller.messages.length,
        itemBuilder: (context, index) {
          final message = controller.messages[index];
          return MessageBubble(message: message, controller: controller);
        },
      );
    });
  }
}

