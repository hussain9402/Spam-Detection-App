import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../controllers/spam_controller.dart';
import '../../models/spam_model.dart';
import 'spam_message_tile.dart';

/// All spam messages for a single chat.
class SpamChatThreadScreen extends StatefulWidget {
  const SpamChatThreadScreen({
    super.key,
    required this.chatId,
    required this.chatTitle,
  });

  final String chatId;
  final String chatTitle;

  @override
  State<SpamChatThreadScreen> createState() => _SpamChatThreadScreenState();
}

class _SpamChatThreadScreenState extends State<SpamChatThreadScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Get.isRegistered<SpamController>()) {
          Get.find<SpamController>().scheduleScrollToSpamHighlight();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final SpamController controller = Get.find<SpamController>();

    return Obx(() {
      controller.highlightedSpamMessageId.value;
      final List<SpamMessage> items =
          controller.spamMessagesForChat(widget.chatId);

      return Scaffold(
        backgroundColor: AppColors.headerDarkGreen,
        appBar: AppBar(
          backgroundColor: AppColors.headerDarkGreen,
          foregroundColor: AppColors.primaryTeal,
          elevation: 0,
          centerTitle: true,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.chatTitle,
                style: const TextStyle(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                items.length == 1 ? '1 spam' : '${items.length} spam',
                style: TextStyle(
                  color: AppColors.primaryTeal.withOpacity(0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No spam messages in this chat.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  children: items.map((SpamMessage spam) {
                    final String? h =
                        controller.highlightedSpamMessageId.value;
                    final bool isHighlight = h != null && h == spam.id;
                    return SpamMessageListTile(
                      spam: spam,
                      controller: controller,
                      isHighlight: isHighlight,
                      scrollTargetKey: isHighlight
                          ? controller.spamMessageHighlightKey
                          : null,
                    );
                  }).toList(),
                ),
        ),
      );
    });
  }
}
