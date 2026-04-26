import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spamdetection/core/constants/app_colors.dart';
import 'package:spamdetection/features/chat/models/message_model.dart';
import 'package:spamdetection/features/chat/models/spam_model.dart';
import 'package:spamdetection/features/chat/views/chat_detail/widgets/fullscreen_image_viewer.dart';

/// Renders spam payload like the chat thread: full text, image thumbnail + zoom, playable voice.
class SpamMessageContent extends StatelessWidget {
  const SpamMessageContent({super.key, required this.spam});

  final SpamMessage spam;

  static const double _imageMaxSide = 220;

  @override
  Widget build(BuildContext context) {
    switch (spam.messageType) {
      case MessageType.text:
        return _buildText(context);
      case MessageType.image:
        return _buildImage(context);
      case MessageType.voice:
        return _SpamVoiceRow(
          content: spam.content,
          voiceDuration: spam.voiceDuration,
        );
    }
  }

  Widget _buildText(BuildContext context) {
    final String text = spam.content.trim();
    if (text.isEmpty) {
      return Text(
        '—',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      );
    }
    return SelectableText(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 15,
        height: 1.35,
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final String raw = spam.content;
    final String? url = raw.trim().startsWith('http') ? raw.trim() : null;
    final String? filePath = url == null ? raw.trim() : null;

    late final Widget child;
    if (url != null) {
      final int memW =
          (_imageMaxSide * MediaQuery.devicePixelRatioOf(context)).round();
      child = SizedBox(
        width: _imageMaxSide,
        height: _imageMaxSide,
        child: ColoredBox(
          color: Colors.black12,
          child: CachedNetworkImage(
            imageUrl: url,
            width: _imageMaxSide,
            height: _imageMaxSide,
            fit: BoxFit.contain,
            alignment: Alignment.center,
            memCacheWidth: memW,
            placeholder: (_, __) => const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryTeal,
              ),
            ),
            errorWidget: (_, __, ___) => _imageError(context),
          ),
        ),
      );
    } else if (filePath != null &&
        filePath.isNotEmpty &&
        File(filePath).existsSync()) {
      child = SizedBox(
        width: _imageMaxSide,
        height: _imageMaxSide,
        child: ColoredBox(
          color: Colors.black12,
          child: Image.file(
            File(filePath),
            width: _imageMaxSide,
            height: _imageMaxSide,
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        ),
      );
    } else {
      child = _imageError(context);
    }

    final bool canOpen = url != null ||
        (filePath != null &&
            filePath.isNotEmpty &&
            File(filePath).existsSync());

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canOpen
            ? () => ChatFullScreenImageViewer.open(
                  context,
                  imageUrl: url,
                  imagePath: url == null ? filePath : null,
                )
            : null,
        borderRadius: BorderRadius.circular(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: child,
        ),
      ),
    );
  }

  Widget _imageError(BuildContext context) {
    return Container(
      width: _imageMaxSide,
      height: 120,
      color: Colors.black26,
      alignment: Alignment.center,
      child: Icon(
        Icons.broken_image_outlined,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      ),
    );
  }
}

class _SpamVoiceRow extends StatefulWidget {
  const _SpamVoiceRow({
    required this.content,
    required this.voiceDuration,
  });

  final String content;
  final int? voiceDuration;

  @override
  State<_SpamVoiceRow> createState() => _SpamVoiceRowState();
}

class _SpamVoiceRowState extends State<_SpamVoiceRow> {
  late final AudioPlayer _player = AudioPlayer();
  bool _playing = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;

  @override
  void initState() {
    super.initState();
    _stateSub = _player.onPlayerStateChanged.listen((PlayerState s) {
      if (mounted) {
        setState(() {
          _playing = s == PlayerState.playing;
        });
      }
    });
    _posSub = _player.onPositionChanged.listen((Duration d) {
      if (mounted) {
        setState(() => _position = d);
      }
    });
    _durSub = _player.onDurationChanged.listen((Duration d) {
      if (mounted) {
        setState(() => _duration = d);
      }
    });
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_playing) {
      await _player.pause();
      return;
    }
    final String c = widget.content;
    if (c.startsWith('http')) {
      await _player.play(UrlSource(c));
    } else if (c.isNotEmpty && File(c).existsSync()) {
      await _player.play(DeviceFileSource(c));
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = 0;
    final int dMs = _duration.inMilliseconds;
    if (dMs > 0) {
      progress =
          (_position.inMilliseconds / dMs).clamp(0.0, 1.0).toDouble();
    }
    int totalSeconds = widget.voiceDuration ?? 0;
    if (totalSeconds == 0 && _duration.inSeconds > 0) {
      totalSeconds = _duration.inSeconds;
    }
    final int displaySeconds = _playing && _position.inSeconds > 0
        ? _position.inSeconds
        : totalSeconds;
    final String mm = (displaySeconds ~/ 60).toString().padLeft(2, '0');
    final String ss = (displaySeconds % 60).toString().padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _toggle,
          child: Icon(
            _playing ? Icons.pause : Icons.play_arrow,
            color: AppColors.primaryTeal,
            size: 24,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 140,
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AppColors.primaryTeal.withOpacity(0.2),
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$mm:$ss',
          style: const TextStyle(
            color: AppColors.textGray,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
