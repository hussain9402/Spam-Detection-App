import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../controllers/spam_controller.dart';
import '../../models/spam_model.dart';

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.headerDarkGreen,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.search, color: AppColors.textWhite),
                    onPressed: () {},
                  ),
                  const Expanded(
                    child: Text(
                      'Spam',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: AppColors.textWhite),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Obx(() {
                    if (controller.spamMessages.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Spam Protection Summary Banner
                        _buildProtectionBanner(context, controller),

                        // Caution Banner
                        _buildCautionBanner(context),

                        const SizedBox(height: 16),

                        // Spam Messages List Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Blocked Messages',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // List of Spam Items
                        ...controller.spamMessages.map((spam) {
                          return _buildSpamItem(context, spam, controller);
                        }),

                        const SizedBox(height: 16),
                      ],
                    );
                  }),
                ),
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
          borderRadius: BorderRadius.circular(8),
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

  Widget _buildSpamItem(BuildContext context, SpamMessage spam, SpamController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2A2A2A)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getCategoryColor(spam.category),
                  child: Text(spam.senderName[0].toUpperCase(), 
                    style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(spam.senderName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(spam.senderPhone, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => controller.deleteSpamMessage(spam.id),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(spam.messageContent, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_getTimeString(spam.receivedTime), style: const TextStyle(fontSize: 11)),
                _buildRiskBadge(spam),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRiskBadge(SpamMessage spam) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: spam.riskLevel.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        spam.riskLevel.label,
        style: TextStyle(fontSize: 11, color: spam.riskLevel.color, fontWeight: FontWeight.bold),
      ),
    );
  }

  // --- Logic Helpers ---

  String _getTimeString(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return 'Older than a week';
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'unknown number': return Colors.purple;
      case 'promotional': return Colors.blue;
      case 'spam bot': return Colors.green;
      default: return Colors.grey;
    }
  }
}