import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../controllers/message_detail_controller.dart';
import '../../models/message_model.dart';
import '../../models/chat_model.dart';

class ChatDetailScreen extends StatelessWidget {
  final ChatModel chat;

  const ChatDetailScreen({
    super.key,
    required this.chat,
  });

  @override
  Widget build(BuildContext context) {
    final MessageDetailController controller = Get.put(
      MessageDetailController(),
      tag: chat.id,
    );
    
    // Initialize controller with chat data
    if (controller.chat.value == null) {
      controller.initializeWithChat(chat);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, chat),
            
            // Chat Messages
            Expanded(
              child: Obx(() => _buildChatMessages(context, controller)),
            ),
            
            // Message Input Bar
            Obx(() => _buildMessageInput(context, controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ChatModel chat) {
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
          // Back Button
          IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          
          // Profile Picture with Active Indicator
          Stack(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.yellow[700],
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.textWhite,
                  size: 28,
                ),
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
          ),
          
          const SizedBox(width: 12),
          
          // Name and Status
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
                const SizedBox(height: 2),
                Text(
                  localizations.activeNow,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLightGray,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          
          // Call Icons
          IconButton(
            icon: Icon(Icons.phone, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.videocam, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages(BuildContext context, MessageDetailController controller) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    
    if (controller.messages.isEmpty) {
      return const Center(
        child: Text(
          'No messages yet',
          style: TextStyle(color: AppColors.textLightGray),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      reverse: false,
      itemCount: controller.messages.length + 1, // +1 for date separator
      itemBuilder: (context, index) {
        if (index == 0) {
          // Date Separator
          return _buildDateSeparator(context, localizations.today);
        }
        
        final message = controller.messages[index - 1];
        final isDifferentDay = index > 1 &&
            controller.messages[index - 1].timestamp.day !=
                controller.messages[index - 2].timestamp.day;
        
        return Column(
          children: [
            if (isDifferentDay)
              _buildDateSeparator(
                context,
                _formatDate(message.timestamp, localizations),
              ),
            _buildMessageBubble(context, message, controller),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildDateSeparator(BuildContext context, String date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.backgroundDarkSurface.withOpacity(0.6)
                : AppColors.backgroundLightGray,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            date,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textLightGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    MessageModel message,
    MessageDetailController controller,
  ) {
        if (message.isSent) {
      // Outgoing message (right-aligned)
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
                        ? AppColors.primaryTeal.withOpacity(0.8)
                        : AppColors.primaryTeal,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: message.type == MessageType.voice
                      ? _buildVoiceMessage(message)
                      : Text(
                          message.content,
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              controller.formatTime(message.timestamp),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textLightGray,
              ),
            ),
          ),
        ],
      );
    } else {
      // Incoming message (left-aligned)
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Picture
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.yellow[700],
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.textWhite,
              size: 20,
            ),
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
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLightGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildVoiceMessage(MessageModel message) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.play_arrow,
          color: AppColors.textWhite,
          size: 24,
        ),
        const SizedBox(width: 8),
        // Waveform visualization (simplified)
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
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput(BuildContext context, MessageDetailController controller) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final textController = TextEditingController(text: controller.messageText.value);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.borderDark
                : AppColors.borderGray,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Attachment Icon
          IconButton(
            icon: const Icon(Icons.attach_file, color: AppColors.textLightGray),
            onPressed: () {},
          ),
          
          // Text Input Field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.backgroundDarkSurface.withOpacity(0.6)
                    : AppColors.backgroundLightGray,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      onChanged: (value) {
                        controller.messageText.value = value;
                      },
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: localizations.writeYourMessage,
                        hintStyle: TextStyle(
                          color: AppColors.textLightGray,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) {
                        controller.sendMessage();
                        textController.clear();
                      },
                    ),
                  ),
                  // Emoji Icon inside input
                  IconButton(
                    icon: const Icon(
                      Icons.tag_faces,
                      color: AppColors.textLightGray,
                      size: 24,
                    ),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Camera Icon
          IconButton(
            icon: const Icon(Icons.camera_alt, color: AppColors.textLightGray),
            onPressed: () {},
          ),
          
          // Microphone Icon
          IconButton(
            icon: const Icon(Icons.mic, color: AppColors.textLightGray),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date, AppLocalizations localizations) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return localizations.today;
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday'; // TODO: Add to localization
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

