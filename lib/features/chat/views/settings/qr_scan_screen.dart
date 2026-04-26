import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:spamdetection/core/constants/app_colors.dart';
import 'package:spamdetection/features/chat/services/chat_deep_link_service.dart';

/// Opens the device camera to scan a [spamdetection] chat QR or a plain phone value.
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen>
    with SingleTickerProviderStateMixin {
  bool _handled = false;
  late AnimationController _lineController;

  @override
  void initState() {
    super.initState();
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _lineController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) {
      return;
    }
    for (final Barcode b in capture.barcodes) {
      final String? v = b.rawValue;
      if (v == null || v.isEmpty) {
        continue;
      }
      _handled = true;
      Get.back<void>();
      if (Get.isRegistered<ChatDeepLinkService>()) {
        Get.find<ChatDeepLinkService>().handleScannedQrPayload(v);
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan QR code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Size size = constraints.biggest;
          final double side = size.width * 0.72;
          final double left = (size.width - side) / 2;
          final double top = size.height * 0.14;
          final Rect window = Rect.fromLTWH(left, top, side, side);

          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              MobileScanner(
                onDetect: _onDetect,
              ),
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: _lineController,
                  builder: (BuildContext context, Widget? child) {
                    return CustomPaint(
                      size: size,
                      painter: _QrScanOverlayPainter(
                        window: window,
                        lineT: _lineController.value,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 28,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Align the QR inside the frame. The line shows the active scan area.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 13,
                      height: 1.35,
                      shadows: const <Shadow>[
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black87,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Dimmed mask with a clear square, corner brackets, and a moving scan line.
class _QrScanOverlayPainter extends CustomPainter {
  _QrScanOverlayPainter({
    required this.window,
    required this.lineT,
  });

  final Rect window;
  /// 0 = top of scan band, 1 = bottom (inside window, inset slightly).
  final double lineT;

  static const double _cornerLen = 28;
  static const double _stroke = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect hole = RRect.fromRectAndRadius(
      window,
      const Radius.circular(14),
    );
    final Path outer = Path()..addRect(Offset.zero & size);
    final Path inner = Path()..addRRect(hole);
    final Path mask = Path.combine(PathOperation.difference, outer, inner);
    canvas.drawPath(
      mask,
      Paint()..color = const Color(0xAA000000),
    );

    final Paint cornerPaint = Paint()
      ..color = AppColors.primaryTeal
      ..strokeWidth = _stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    void cornerL(double x, double y, bool top, bool left) {
      final double dx = left ? 1 : -1;
      final double dy = top ? 1 : -1;
      canvas.drawPath(
        Path()
          ..moveTo(x, y + dy * _cornerLen)
          ..lineTo(x, y)
          ..lineTo(x + dx * _cornerLen, y),
        cornerPaint,
      );
    }

    cornerL(window.left, window.top, true, true);
    cornerL(window.right, window.top, true, false);
    cornerL(window.left, window.bottom, false, true);
    cornerL(window.right, window.bottom, false, false);

    const double inset = 6;
    final double innerH = (window.height - 2 * inset).clamp(4.0, window.height);
    final double lineY =
        window.top + inset + innerH * lineT.clamp(0.0, 1.0);

    final Rect lineRect = Rect.fromLTWH(
      window.left + inset,
      lineY - 1.5,
      window.width - 2 * inset,
      3,
    );

    canvas.drawRect(
      lineRect,
      Paint()
        ..shader = LinearGradient(
          colors: <Color>[
            AppColors.primaryTeal.withValues(alpha: 0.15),
            AppColors.primaryTeal,
            AppColors.primaryTeal.withValues(alpha: 0.15),
          ],
          stops: const <double>[0.0, 0.5, 1.0],
        ).createShader(lineRect),
    );
    canvas.drawLine(
      lineRect.topLeft,
      lineRect.topRight,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant _QrScanOverlayPainter oldDelegate) {
    return oldDelegate.window != window || oldDelegate.lineT != lineT;
  }
}
