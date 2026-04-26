import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Fullscreen image with pinch-zoom; opened from chat thumbnails and spam inbox.
class ChatFullScreenImageViewer extends StatelessWidget {
  const ChatFullScreenImageViewer({
    super.key,
    required this.imageUrl,
    required this.imagePath,
  });

  final String? imageUrl;
  final String? imagePath;

  static void open(
    BuildContext context, {
    String? imageUrl,
    String? imagePath,
  }) {
    final bool hasUrl = imageUrl != null && imageUrl.startsWith('http');
    final bool hasFile = imagePath != null &&
        imagePath.isNotEmpty &&
        File(imagePath).existsSync();
    if (!hasUrl && !hasFile) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (BuildContext context) => ChatFullScreenImageViewer(
          imageUrl: hasUrl ? imageUrl : null,
          imagePath: hasUrl ? null : imagePath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double w = constraints.maxWidth;
          final double h = constraints.maxHeight;
          if (imageUrl != null) {
            final int memW =
                (w * MediaQuery.devicePixelRatioOf(context)).round().clamp(
                      1,
                      2048,
                    );
            return InteractiveViewer(
              minScale: 0.5,
              maxScale: 5,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: imageUrl!,
                  width: w,
                  height: h,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  memCacheWidth: memW,
                  placeholder: (BuildContext context, String url) => SizedBox(
                    width: w,
                    height: h,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white54,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget:
                      (BuildContext context, String url, Object error) =>
                          SizedBox(
                    width: w,
                    height: h,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white38,
                        size: 64,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          final String? path = imagePath;
          if (path != null && File(path).existsSync()) {
            return InteractiveViewer(
              minScale: 0.5,
              maxScale: 5,
              child: Center(
                child: Image.file(
                  File(path),
                  width: w,
                  height: h,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => SizedBox(
                    width: w,
                    height: h,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white38,
                        size: 64,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return const Center(
            child: Icon(Icons.broken_image_outlined, color: Colors.white38, size: 64),
          );
        },
      ),
    );
  }
}
