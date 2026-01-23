import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:spamdetection/core/constants/app_colors.dart';
import 'package:spamdetection/core/localization/app_localizations.dart';
import 'package:spamdetection/features/chat/controllers/message_detail_controller.dart';

class ChatInputField extends StatefulWidget {
  final MessageDetailController controller;

  const ChatInputField({super.key, required this.controller});

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  late final TextEditingController _textController;
  final RxBool _isTyping = false.obs;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();

    _textController.addListener(() {
      final isNotEmpty = _textController.text.trim().isNotEmpty;
      if (_isTyping.value != isNotEmpty) {
        _isTyping.value = isNotEmpty;
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final String val = _textController.text.trim();
    if (val.isNotEmpty) {
      widget.controller.messageText.value = val;
      widget.controller.sendMessage();
      _textController.clear();
      widget.controller.messageText.value = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderGray,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_file, color: AppColors.primaryTeal),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                // FIX: Matching background color to the theme
                color: isDark
                    ? AppColors.backgroundDarkSurface.withOpacity(0.6)
                    : AppColors.backgroundLightGray,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.sentiment_satisfied_alt_outlined,
                      color: AppColors.primaryTeal,
                    ),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: localizations.writeYourMessage,
                        hintStyle: const TextStyle(
                          color: AppColors.textLightGray,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _isTyping.value ? _handleSend() : null,
            child: CircleAvatar(
              backgroundColor: AppColors.primaryTeal.withAlpha(50),
              radius: 22,
              // Obx is ONLY here. It doesn't touch the TextField.
              child: Obx(
                () => Icon(
                  _isTyping.value ? Icons.send : Icons.mic,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
