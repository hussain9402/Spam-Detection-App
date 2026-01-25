import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spamdetection/core/constants/app_colors.dart';
import 'package:spamdetection/features/chat/controllers/message_detail_controller.dart';
import 'package:spamdetection/features/chat/models/message_model.dart';

class MessageBubble extends StatefulWidget {
  final MessageModel message;
  final MessageDetailController controller;

  const MessageBubble({
    super.key,
    required this.message,
    required this.controller,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final RxBool _isPlaying = false.obs;
  final Rx<Duration> _position = Duration.zero.obs;
  final Rx<Duration> _duration = Duration.zero.obs;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying.value = state == PlayerState.playing;
    });
    _audioPlayer.onDurationChanged.listen((d) {
      _duration.value = d;
    });
    _audioPlayer.onPositionChanged.listen((p) {
      _position.value = p;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying.value) {
      await _audioPlayer.pause();
    } else {
      if (widget.message.content.startsWith('http')) {
        // Play from URL (Sent/Received)
        await _audioPlayer.play(UrlSource(widget.message.content));
      } else if (widget.message.localPath != null || !widget.message.content.startsWith('http')) {
        // Play from local file (Failed/Sending)
        final path = widget.message.localPath ?? widget.message.content;
        if (await File(path).exists()) {
          await _audioPlayer.play(DeviceFileSource(path));
        } else {
          Get.snackbar("Error", "Local audio file not found");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.message.isSent) {
      return _buildSentMessage(context);
    } else {
      return _buildReceivedMessage(context);
    }
  }

  Widget _buildSentMessage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (widget.message.status == MessageStatus.failed)
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.red, size: 20),
                onPressed: () => widget.controller.resendMessage(widget.message),
              ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.message.status == MessageStatus.failed
                      ? Colors.red.withOpacity(0.2)
                      : (Theme.of(context).brightness == Brightness.dark
                          ? AppColors.primaryTeal.withAlpha(50)
                          : AppColors.primaryTeal),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: widget.message.type == MessageType.voice
                    ? _buildVoiceMessage()
                    : Text(
                        widget.message.content,
                        style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
                      ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.controller.formatTime(widget.message.timestamp),
              style: const TextStyle(fontSize: 11, color: AppColors.textLightGray),
            ),
            const SizedBox(width: 4),
            if (widget.message.status == MessageStatus.sending)
              const SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(strokeWidth: 1, color: AppColors.textLightGray),
              )
            else if (widget.message.status == MessageStatus.failed)
              const Icon(Icons.error_outline, color: Colors.red, size: 12)
            else
              const Icon(Icons.done_all, color: AppColors.primaryTeal, size: 12),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildReceivedMessage(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.yellow[700],
          child: const Icon(Icons.person, color: AppColors.textWhite, size: 20),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.message.senderName,
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
                child: widget.message.type == MessageType.voice
                    ? _buildVoiceMessage()
                    : Text(
                        widget.message.content,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                        ),
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.controller.formatTime(widget.message.timestamp),
                style: const TextStyle(fontSize: 11, color: AppColors.textLightGray),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceMessage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _togglePlayback,
          child: Obx(() => Icon(
                _isPlaying.value ? Icons.pause : Icons.play_arrow,
                color: widget.message.isSent ? AppColors.textWhite : AppColors.primaryTeal,
                size: 24,
              )),
        ),
        const SizedBox(width: 8),
        Obx(() {
          double progress = 0.0;
          if (_duration.value.inMilliseconds > 0) {
            progress = _position.value.inMilliseconds / _duration.value.inMilliseconds;
          }
          return SizedBox(
            width: 100,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: widget.message.isSent
                  ? Colors.white.withOpacity(0.3)
                  : AppColors.primaryTeal.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.message.isSent ? Colors.white : AppColors.primaryTeal,
              ),
            ),
          );
        }),
        const SizedBox(width: 8),
        Obx(() {
          // Show total duration from message, or current position if playing
          int totalSeconds = widget.message.voiceDuration ?? 0;
          if (totalSeconds == 0 && _duration.value.inSeconds > 0) {
            totalSeconds = _duration.value.inSeconds;
          }
          
          // If playing, show current position, otherwise show total duration
          int displaySeconds = _isPlaying.value && _position.value.inSeconds > 0
              ? _position.value.inSeconds
              : totalSeconds;
          
          final minutes = displaySeconds ~/ 60;
          final seconds = displaySeconds % 60;
          return Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: widget.message.isSent ? AppColors.textWhite : AppColors.textGray,
              fontSize: 12,
            ),
          );
        }),
      ],
    );
  }
}