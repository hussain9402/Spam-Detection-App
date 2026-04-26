import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/message_detail_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../models/chat_model.dart';
import 'widgets/chat_header.dart';
import 'widgets/chat_message_list.dart';
import 'widgets/chat_input_field.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatModel chat;

  const ChatDetailScreen({super.key, required this.chat});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late MessageDetailController controller;

  @override
  void initState() {
    super.initState();
    // 1. Initialize with tag to keep chats separate
    controller = Get.put(MessageDetailController(), tag: widget.chat.id);

    // 2. Initializing data only if it hasn't been set
    if (controller.chat.value == null) {
      controller.initializeWithChat(widget.chat);
    }
  }

  @override
  void dispose() {
    // 3. IMPORTANT: Delete the controller when leaving the screen
    // to free up memory and prevent 'stuck' logic.
    Get.delete<MessageDetailController>(tag: widget.chat.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) {
          return;
        }
        if (controller.isSelectionMode.value) {
          controller.exitSelectionMode();
          return;
        }
        if (Get.isRegistered<NavigationController>()) {
          Get.find<NavigationController>().goToMessagesTab();
        }
        Get.back();
      },
      child: Scaffold(
        // Keep background dynamic based on theme
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              ChatHeader(chat: widget.chat, controller: controller),
              Expanded(
                // The Obx is inside ChatMessageList, so we don't need it here.
                child: ChatMessageList(controller: controller),
              ),
              Obx(() {
                if (controller.isSelectionMode.value) {
                  return const SizedBox.shrink();
                }
                return ChatInputField(controller: controller);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
