import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton placeholders while chat messages load from Firestore.
class ChatMessagesShimmer extends StatelessWidget {
  const ChatMessagesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color base = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8);
    final Color highlight = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      period: const Duration(milliseconds: 1200),
      child: ListView.builder(
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        itemCount: 12,
        itemBuilder: (BuildContext context, int index) {
          final bool alignEnd = index % 3 != 0;
          final double widthFactor = 0.32 + (index % 5) * 0.06;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              mainAxisAlignment:
                  alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!alignEnd) _avatarPlaceholder(context),
                if (!alignEnd) const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * widthFactor,
                      minWidth: 72,
                      minHeight: 44,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF333333) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(alignEnd ? 16 : 4),
                        topRight: Radius.circular(16),
                        bottomLeft: const Radius.circular(16),
                        bottomRight: Radius.circular(alignEnd ? 4 : 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _avatarPlaceholder(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF333333)
            : Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}
