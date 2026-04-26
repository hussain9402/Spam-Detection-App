import 'dart:async';

import 'package:flutter/material.dart';

import '../../controllers/spam_controller.dart';
import '../../models/spam_model.dart';

/// Single spam message row (used on main spam list thread and per-chat screen).
class SpamMessageListTile extends StatelessWidget {
  const SpamMessageListTile({
    super.key,
    required this.spam,
    required this.controller,
    required this.isHighlight,
    this.scrollTargetKey,
  });

  final SpamMessage spam;
  final SpamController controller;
  final bool isHighlight;

  /// When non-null, used as [Padding.key] for [Scrollable.ensureVisible] (e.g. highlight from chat).
  final Key? scrollTargetKey;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      key: scrollTargetKey,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isHighlight
              ? (isDark
                  ? const Color(0xFF2D3A1F)
                  : const Color(0xFFFFF8E1))
              : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isHighlight
                ? const Color(0xFFFFA000)
                : Colors.grey.withOpacity(0.3),
            width: isHighlight ? 2.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: spamCategoryColor(spam.category),
                  child: Text(
                    spam.senderName.isNotEmpty
                        ? spam.senderName[0].toUpperCase()
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
                        spam.senderName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (hasDistinctPhoneLine(spam))
                        Text(
                          spam.senderPhone,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => showRemoveSpamMessageDialog(
                    context,
                    controller,
                    spam,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              spam.messageContent,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  spamTimeLabel(spam.receivedTime),
                  style: const TextStyle(fontSize: 11),
                ),
                spamRiskBadge(spam),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget spamRiskBadge(SpamMessage spam) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: spam.riskLevel.color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      spam.riskLevel.label,
      style: TextStyle(
        fontSize: 11,
        color: spam.riskLevel.color,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Color spamCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'unknown number':
      return Colors.purple;
    case 'promotional':
      return Colors.blue;
    case 'spam bot':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

bool hasDistinctPhoneLine(SpamMessage spam) {
  final String name = spam.senderName.trim();
  final String phone = spam.senderPhone.trim();
  if (phone.isEmpty || phone == '—') {
    return false;
  }
  if (name == phone) {
    return false;
  }
  final RegExp onlyDigits = RegExp(r'^[\d+\s\-\(\)]+$');
  if (onlyDigits.hasMatch(name) && onlyDigits.hasMatch(phone)) {
    final String nd = name.replaceAll(RegExp(r'[^\d]'), '');
    final String pd = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (nd.isNotEmpty && pd.isNotEmpty && nd == pd) {
      return false;
    }
  }
  return true;
}

String spamTimeLabel(DateTime time) {
  final DateTime now = DateTime.now();
  final Duration difference = now.difference(time);
  if (difference.inDays == 0) {
    return 'Today';
  }
  if (difference.inDays == 1) {
    return 'Yesterday';
  }
  if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  }
  return 'Older than a week';
}

void showRemoveSpamMessageDialog(
  BuildContext context,
  SpamController controller,
  SpamMessage spam,
) {
  showDialog<void>(
    context: context,
    builder: (BuildContext ctx) {
      return AlertDialog(
        title: const Text('Remove this message?'),
        content: const Text(
          'This message will be removed from the chat and from your spam list.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              unawaited(
                controller.softDeleteFromSpamInbox(
                  spam.chatId,
                  spam.messageId,
                ),
              );
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
