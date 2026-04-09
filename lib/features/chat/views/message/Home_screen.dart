import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spamdetection/features/chat/views/contacts/contacts_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../controllers/chat_controller.dart';
import '../../models/chat_model.dart';
import '../chat_detail/chat_detail_screen.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Initialize the Controller
   final ChatController controller = Get.put(ChatController());
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.headerDarkGreen,
      body: SafeArea( 
        child: Column(
          children: [
            // Header Section
            _buildHeader(context, localizations),

            // Chat List Container
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: Column(
                  children: [
                    // Small drag indicator
                   

                    // 2. Wrap ListView in Obx to react to Firestore data
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (controller.chats.isEmpty) {
                          return _buildEmptyState(localizations);
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.only(top: 8),
                          itemCount: controller.chats.length,
                          itemBuilder: (context, index) {
                            final chat = controller.chats[index];
                            return _buildChatItem(context, chat, controller);
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => Get.to(() => const ContactsScreen()),
      //   backgroundColor: AppColors.primaryTeal.withAlpha(50),
      //   child: const Icon(Icons.contacts, color: AppColors.primaryTeal),
      // ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      color: AppColors.headerDarkGreen,
      child: Row(
        children: [
          // IconButton(
          //   icon: const Icon(Icons.search, color: AppColors.textWhite),
          //   onPressed: () {Get.to(() =>  UserProfileScreen(user: AuthController().currentUser.value!));},
          // ),
          Expanded(
            child: Text(
              localizations.home,
              style: const TextStyle(
                color: AppColors.primaryTeal,
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // CircleAvatar(
          //   backgroundColor: AppColors.primaryTeal.withAlpha(50),
          //   child:  Icon(Icons.person, color: AppColors.primaryTeal),
          // ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textGray.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            "No conversations yet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text("Tap the contact icon to start chatting"),
        ],
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, ChatModel chat, ChatController controller) {
    return InkWell(
      onTap: () => Get.to(() => ChatDetailScreen(chat: chat)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primaryTeal.withAlpha(50),
              child: Icon(
                chat.isGroup ? Icons.group : Icons.person,
                color: AppColors.primaryTeal,
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
                  Row(
                    children: [
                      if (chat.lastMessage.toLowerCase().contains('voice message') ||
                          chat.lastMessage.contains('🎤'))
                        const Icon(
                          Icons.mic,
                          size: 14,
                          color: AppColors.primaryTeal,
                        ),
                      if (chat.lastMessage.toLowerCase().contains('voice message') ||
                          chat.lastMessage.contains('🎤'))
                        const SizedBox(width: 4),
                      if (chat.lastMessage.contains('📷') ||
                          chat.lastMessage.toLowerCase().contains('photo'))
                        const Icon(
                          Icons.image_outlined,
                          size: 14,
                          color: AppColors.primaryTeal,
                        ),
                      if (chat.lastMessage.contains('📷') ||
                          chat.lastMessage.toLowerCase().contains('photo'))
                        const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: chat.unreadCount > 0
                                ? Theme.of(context).colorScheme.onSurface
                                : AppColors.textLightGray,
                            fontWeight: chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
                  style: const TextStyle(fontSize: 12, color: AppColors.textLightGray),
                ),
                if (chat.unreadCount > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.unreadBadge,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${chat.unreadCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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