import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final FocusNode _messageFocusNode = FocusNode();
  final RxBool _isTyping = false.obs;
  bool _emojiPickerVisible = false;

  static const double _emojiPanelHeight = 280;

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

    _messageFocusNode.addListener(() {
      if (_messageFocusNode.hasFocus && _emojiPickerVisible) {
        setState(() => _emojiPickerVisible = false);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _toggleEmojiPicker() {
    if (widget.controller.isRecording.value) return;
    setState(() {
      _emojiPickerVisible = !_emojiPickerVisible;
      if (_emojiPickerVisible) {
        _messageFocusNode.unfocus();
        FocusScope.of(context).unfocus();
      }
    });
  }

  void _handleSend() {
    final String val = _textController.text.trim();
    if (val.isNotEmpty) {
      widget.controller.messageText.value = val;
      widget.controller.sendMessage();
      _textController.clear();
      widget.controller.messageText.value = '';
      if (_emojiPickerVisible) {
        setState(() => _emojiPickerVisible = false);
      }
    }
  }

  void _handleVoiceAction() {
    if (widget.controller.isRecording.value) {
      widget.controller.stopRecording();
    } else {
      if (_emojiPickerVisible) {
        setState(() => _emojiPickerVisible = false);
      }
      widget.controller.startRecording();
    }
  }

  Config _emojiConfig(bool isDark) {
    final bg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);
    final surface = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    return Config(
      height: _emojiPanelHeight,
      checkPlatformCompatibility: true,
      viewOrderConfig: const ViewOrderConfig(),
      emojiViewConfig: EmojiViewConfig(
        emojiSizeMax: 28 *
            (foundation.defaultTargetPlatform == foundation.TargetPlatform.iOS
                ? 1.2
                : 1.0),
        backgroundColor: surface,
      ),
      skinToneConfig: const SkinToneConfig(),
      categoryViewConfig: CategoryViewConfig(
        backgroundColor: bg,
        indicatorColor: AppColors.primaryTeal,
        iconColor: isDark ? Colors.white54 : Colors.black45,
        iconColorSelected: AppColors.primaryTeal,
        backspaceColor: AppColors.primaryTeal,
      ),
      bottomActionBarConfig: BottomActionBarConfig(
        backgroundColor: bg,
        buttonIconColor: isDark ? Colors.white70 : Colors.black54,
        buttonColor: Colors.transparent,
      ),
      searchViewConfig: SearchViewConfig(
        backgroundColor: surface,
        buttonIconColor: AppColors.primaryTeal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
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
              Obx(() => IconButton(
                    tooltip: 'Send image',
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 40),
                    icon: const Icon(Icons.image_outlined,
                        color: AppColors.primaryTeal),
                    onPressed: widget.controller.isRecording.value
                        ? null
                        : () {
                            if (_emojiPickerVisible) {
                              setState(() => _emojiPickerVisible = false);
                            }
                            widget.controller.pickAndSendImage();
                          },
                  )),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.backgroundDarkSurface.withOpacity(0.6)
                        : AppColors.backgroundLightGray,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Obx(() => IconButton(
                            tooltip: 'Emoji',
                            icon: Icon(
                              _emojiPickerVisible
                                  ? Icons.keyboard_alt_outlined
                                  : Icons.sentiment_satisfied_alt_outlined,
                              color: AppColors.primaryTeal,
                            ),
                            onPressed: widget.controller.isRecording.value
                                ? null
                                : _toggleEmojiPicker,
                          )),
                      Expanded(
                        child: Obx(() => widget.controller.isRecording.value
                            ? SizedBox(
                                height: 40,
                                child: Row(
                                  children: [
                                    const Text(
                                      "Recording...",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    Obx(() {
                                      final duration = widget
                                          .controller.recordingDuration.value;
                                      final minutes = duration ~/ 60;
                                      final seconds = duration % 60;
                                      return Text(
                                        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              )
                            : TextField(
                                controller: _textController,
                                focusNode: _messageFocusNode,
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
                              )),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () =>
                    _isTyping.value ? _handleSend() : _handleVoiceAction(),
                child: Obx(() => CircleAvatar(
                      backgroundColor: widget.controller.isRecording.value
                          ? Colors.red.withAlpha(50)
                          : AppColors.primaryTeal.withAlpha(50),
                      radius: 22,
                      child: Icon(
                        _isTyping.value
                            ? Icons.send
                            : (widget.controller.isRecording.value
                                ? Icons.stop
                                : Icons.mic),
                        color: widget.controller.isRecording.value
                            ? Colors.red
                            : Colors.white,
                        size: 22,
                      ),
                    )),
              ),
            ],
          ),
        ),
        Offstage(
          offstage: !_emojiPickerVisible,
          child: SizedBox(
            height: _emojiPanelHeight,
            child: EmojiPicker(
              textEditingController: _textController,
              config: _emojiConfig(isDark),
            ),
          ),
        ),
      ],
    );
  }
}
