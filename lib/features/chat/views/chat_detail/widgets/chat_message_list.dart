import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:spamdetection/features/chat/controllers/message_detail_controller.dart';
import 'package:spamdetection/features/chat/views/chat_detail/widgets/message_bubble.dart';

class ChatMessageList extends StatefulWidget {
  final MessageDetailController controller;

  const ChatMessageList({super.key, required this.controller});

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final ScrollController _scrollController = ScrollController();
  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    // Scroll to bottom after first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool smooth = true}) {
    if (_scrollController.hasClients) {
      if (smooth) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final messages = widget.controller.messages;
      final currentCount = messages.length;

      // Auto-scroll when new messages arrive
      if (currentCount > _previousMessageCount && _previousMessageCount > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
      _previousMessageCount = currentCount;

      if (messages.isEmpty) {
        return const Center(child: Text('No messages yet'));
      }

      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          
          // Logic to determine if we should show a date separator
          bool showDateHeader = false;
          if (index == 0) {
            showDateHeader = true; // Always show date for the first message
          } else {
            final prevMessage = messages[index - 1];
            // If the date (Year/Month/Day) is different from the previous message
            if (message.timestamp.year != prevMessage.timestamp.year ||
                message.timestamp.month != prevMessage.timestamp.month ||
                message.timestamp.day != prevMessage.timestamp.day) {
              showDateHeader = true;
            }
          }

          return Column(
            children: [
              if (showDateHeader) _buildDateHeader(message.timestamp, context),
              MessageBubble(message: message, controller: widget.controller),
            ],
          );
        },
      );
    });
  }

  Widget _buildDateHeader(DateTime date, BuildContext context) {
    String dateText = _getFormattedDate(date);
    
    return Center(
      child: Container(
        // margin: const EdgeInsets.symmetric(vertical: 20),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.blueGrey.withOpacity(0.2) 
              : Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          dateText,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  String _getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(date.year, date.month, date.day);

    if (msgDate == today) {
      return "Today";
    } else if (msgDate == yesterday) {
      return "Yesterday";
    } else if (now.difference(msgDate).inDays < 7) {
      return DateFormat('EEEE').format(date); // Show day name (e.g., Monday)
    } else {
      return DateFormat('d MMMM yyyy').format(date); // Show full date
    }
  }
}