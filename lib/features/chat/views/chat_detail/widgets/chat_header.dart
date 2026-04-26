import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spamdetection/core/constants/app_colors.dart';
import 'package:spamdetection/core/localization/app_localizations.dart';
import 'package:spamdetection/features/chat/controllers/call_controller.dart';
import 'package:spamdetection/features/chat/controllers/message_detail_controller.dart';
import 'package:spamdetection/features/chat/controllers/navigation_controller.dart';
import 'package:spamdetection/features/chat/models/chat_model.dart';
import 'package:spamdetection/features/chat/views/calls/Call_UI.dart';
import 'package:spamdetection/features/chat/views/chat_detail/ChatInfoScreen.dart';

class ChatHeader extends StatelessWidget {
  final ChatModel chat;
  final MessageDetailController controller;

  const ChatHeader({
    super.key,
    required this.chat,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isSelectionMode.value) {
        return _buildSelectionBar(context);
      }
      return _buildNormalBar(context);
    });
  }

  Widget _buildSelectionBar(BuildContext context) {
    final int n = controller.selectedMessageIds.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.borderDark
                : AppColors.borderGray,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => controller.exitSelectionMode(),
            tooltip: 'Cancel',
          ),
          Expanded(
            child: Text(
              n == 1 ? '1 selected' : '$n selected',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Delete',
            onPressed: () => _confirmDeleteSelected(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteSelected(BuildContext context) async {
    final int n = controller.selectedMessageIds.length;
    if (n == 0) {
      return;
    }
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Delete messages?'),
          content: Text(
            n == 1
                ? 'This message will be permanently removed for everyone in the chat.'
                : 'Delete $n messages? They will be permanently removed for everyone in the chat.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (ok == true) {
      await controller.deleteSelectedMessages();
    }
  }

  Widget _buildNormalBar(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.borderDark
                : AppColors.borderGray,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (Get.isRegistered<NavigationController>()) {
                Get.find<NavigationController>().goToMessagesTab();
              }
              Get.back();
            },
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => Get.to(() => ChatInfoScreen(chat: chat)),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  _buildProfileStack(context),
                  const SizedBox(width: 12),
                  _buildNameAndStatus(context, localizations),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () async {
              final CallController callController = Get.isRegistered<CallController>()
                  ? Get.find<CallController>()
                  : Get.put(CallController());

              final String receiverId = chat.phoneNumber ?? '';
              if (receiverId.isEmpty) {
                return;
              }

              final String callId =
                  DateTime.now().millisecondsSinceEpoch.toString();

              await callController.createCall(
                receiverId: receiverId,
                isVideo: false,
              );

              Get.to(
                () => CallScreen(
                  callId: callId,
                  channelId: 'call_$callId',
                  isVideo: false,
                  isCaller: true,
                ),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildProfileStack(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 22.5,
          backgroundColor: Colors.yellow[700]?.withAlpha(50),
          child: Icon(Icons.person, color: Colors.yellow[700], size: 28),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
              border: Border.all(
                color: Theme.of(context).scaffoldBackgroundColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameAndStatus(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chat.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textWhite,
            ),
          ),
          Text(
            localizations.activeNow,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textLightGray,
            ),
          ),
        ],
      ),
    );
  }
}
