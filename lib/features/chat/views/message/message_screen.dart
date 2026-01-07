import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../controllers/chat_controller.dart';
import '../../models/chat_model.dart';
import '../chat_detail/chat_detail_screen.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.put(ChatController());
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.headerDarkGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.headerDarkGreen,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.search, color: AppColors.textWhite),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Text(
                      localizations.home,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to profile
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryTeal,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.textWhite,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Chat List
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Small drag indicator
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderGray,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    
                    // Chat List
                    Expanded(
                      child: Obx(() => ListView.builder(
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: controller.chats.length,
                        itemBuilder: (context, index) {
                          final chat = controller.chats[index];
                          return _buildChatItem(context, chat, controller);
                        },
                      )),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, ChatModel chat, ChatController controller) {
    return InkWell(
      onTap: () {
        Get.to(() => ChatDetailScreen(chat: chat));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Profile Picture
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: chat.isGroup 
                    ? AppColors.primaryTeal 
                    : AppColors.headerDarkGreen,
              ),
              child: chat.isGroup
                  ? const Icon(
                      Icons.group,
                      color: AppColors.textWhite,
                      size: 28,
                    )
                  : const Icon(
                      Icons.person,
                      color: AppColors.textWhite,
                      size: 28,
                    ),
            ),
            const SizedBox(width: 16),
            
            // Chat Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: chat.unreadCount > 0
                          ? Theme.of(context).colorScheme.onSurface
                          : AppColors.textLightGray,
                      fontWeight: chat.unreadCount > 0
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Time and Badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  controller.getTimeAgo(chat.lastMessageTime),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLightGray,
                  ),
                ),
                if (chat.unreadCount > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.unreadBadge,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      chat.unreadCount.toString(),
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

