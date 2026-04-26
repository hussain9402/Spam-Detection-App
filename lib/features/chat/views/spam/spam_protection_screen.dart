import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spamdetection/core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';
import '../../controllers/spam_controller.dart';
import '../../models/spam_model.dart';
import 'spam_chat_thread_screen.dart';

class SpamProtectionScreen extends StatelessWidget {
  const SpamProtectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // It's often better to use Get.find if the controller is initialized elsewhere,
    // but Get.put works if this is the entry point.
    final SpamController controller = Get.put(SpamController());

    return Scaffold(
      backgroundColor: AppColors.headerDarkGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              color: AppColors.headerDarkGreen,
              child: Row(
                children: [
                  // IconButton(
                  //   icon: const Icon(Icons.search, color: AppColors.textWhite),
                  //   onPressed: () {},
                  // ),
                  const Expanded(
                    child: Text(
                      AppStrings.Spam,
                      style: TextStyle(
                        color: AppColors.primaryTeal,
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // IconButton(
                  //   icon: const Icon(Icons.more_vert, color: AppColors.textWhite),
                  //   onPressed: () {},
                  // ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: Obx(() {
                    controller.highlightedSpamMessageId.value;
                    controller.spamMessages.length;
                    if (controller.spamChats.isEmpty) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return RefreshIndicator(
                            onRefresh: () async {
                              controller.refreshSpamInbox();
                              await Future<void>.delayed(
                                const Duration(milliseconds: 450),
                              );
                            },
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: _buildEmptyState(context),
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        controller.refreshSpamInbox();
                        await Future<void>.delayed(
                          const Duration(milliseconds: 450),
                        );
                      },
                      child: SingleChildScrollView(
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Spam Protection Summary Banner

                          _buildProtectionBanner(context, controller),

                          // Caution Banner
                          _buildCautionBanner(context),

                          const SizedBox(height: 26),

                          // One row per chat that has spam
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Chats with spam',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          ...controller.spamChats.map((SpamChatSummary summary) {
                            final String? hid =
                                controller.highlightedSpamMessageId.value;
                            String? highlightChatId;
                            if (hid != null) {
                              for (final SpamMessage m
                                  in controller.spamMessages) {
                                if (m.id == hid) {
                                  highlightChatId = m.chatId;
                                  break;
                                }
                              }
                            }
                            final bool isHighlight =
                                highlightChatId != null &&
                                highlightChatId == summary.chatId;
                            return _buildSpamChatRow(
                              context,
                              controller,
                              summary,
                              isHighlight: isHighlight,
                            );
                          }),

                          const SizedBox(height: 16),
                        ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 64,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textLightGray.withOpacity(0.5)
                  : AppColors.textGray.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No spam messages',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your inbox is clean and safe',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtectionBanner(BuildContext context, SpamController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2A3A5E)
              : const Color(0xFFEDF2F9),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30),bottomLeft: Radius.circular(8),bottomRight: Radius.circular(8)),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF4A5A7E)
                : const Color(0xFFD1D9E8),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.shield, color: Color(0xFF64B5F6), size: 40),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Spam Protection',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Obx(() => Text(
                  '${controller.blockedCount.value} blocked messages',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textGray,
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCautionBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1F3A5F)
              : const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFBBDEFB)),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFF1976D2),
              radius: 20,
              child: Icon(Icons.info_outline, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Be cautious', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    'These messages were automatically filtered as potential spam.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpamChatRow(
    BuildContext context,
    SpamController controller,
    SpamChatSummary summary, {
    required bool isHighlight,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String countLine = summary.spamMessageCount == 1
        ? '1 spam'
        : '${summary.spamMessageCount} spam';
    return Padding(
      key: isHighlight ? controller.spamChatRowHighlightKey : null,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            Get.to<void>(
              () => SpamChatThreadScreen(
                chatId: summary.chatId,
                chatTitle: summary.displayTitle,
              ),
              transition: Transition.rightToLeft,
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isHighlight
                  ? (isDark
                      ? const Color(0xFF2D3A1F)
                      : const Color(0xFFFFF8E1))
                  : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isHighlight
                    ? const Color(0xFFFFA000)
                    : Colors.grey.withOpacity(0.3),
                width: isHighlight ? 2.5 : 1,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade600,
                  child: Text(
                    summary.displayTitle.isNotEmpty
                        ? summary.displayTitle[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.displayTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        countLine,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}