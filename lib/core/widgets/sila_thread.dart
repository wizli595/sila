import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The Sila thread — a living wavy line with a small loop.
///
/// Modes:
/// - [SilaThread.ambient]: flows horizontally across the screen (welcome, auth)
/// - [SilaThread.journey]: extends vertically from giver outward (waiting)
/// - [SilaThread.tied]: connects two dots vertically (inbox)
class SilaThread extends StatefulWidget {
  final ThreadMode mode;
  final double thickness;
  final Color? color;

  const SilaThread.ambient({super.key, this.thickness = 1.5, this.color})
      : mode = ThreadMode.ambient;

  const SilaThread.journey({super.key, this.thickness = 2.0, this.color})
      : mode = ThreadMode.journey;

  const SilaThread.tied({super.key, this.thickness = 2.0, this.color})
      : mode = ThreadMode.tied;

  @override
  State<SilaThread> createState() => _SilaThreadState();
}

enum ThreadMode { ambient, journey, tied }

class _SilaThreadState extends State<SilaThread>
    with TickerProviderStateMixin {
  late final AnimationController _drawController;
  late final AnimationController _breathController;
  late final AnimationController _driftController;

  @override
  void initState() {
    super.initState();

    _drawController = AnimationController(
      vsync: this,
      duration: switch (widget.mode) {
        ThreadMode.ambient => const Duration(seconds: 2),
        ThreadMode.journey => const Duration(seconds: 3),
        ThreadMode.tied => const Duration(milliseconds: 1500),
      },
    );

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    switch (widget.mode) {
      case ThreadMode.ambient:
        _drawController.forward();
      case ThreadMode.journey:
        _drawController.forward();
      case ThreadMode.tied:
        _drawController.forward();
    }
  }

  @override
  void dispose() {
    _drawController.dispose();
    _breathController.dispose();
    _driftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_drawController, _breathController, _driftController]),
      builder: (context, _) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ThreadPainter(
            mode: widget.mode,
            draw: _drawController.value,
            breath: _breathController.value,
            drift: _driftController.value,
            thickness: widget.thickness,
            color: widget.color ?? AppColors.watermelon,
          ),
        );
      },
    );
  }
}

class _ThreadPainter extends CustomPainter {
  final ThreadMode mode;
  final double draw;
  final double breath;
  final double drift;
  final double thickness;
  final Color color;

  _ThreadPainter({
    required this.mode,
    required this.draw,
    required this.breath,
    required this.drift,
    required this.thickness,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (mode) {
      case ThreadMode.ambient:
        _paintAmbient(canvas, size);
      case ThreadMode.journey:
        _paintJourney(canvas, size);
      case ThreadMode.tied:
        _paintTied(canvas, size);
    }
  }

  /// Ambient: horizontal wavy line with a small loop — like the mockup
  void _paintAmbient(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cy = h * 0.38;
    final wave = sin(breath * pi) * 6;

    // Start with a small dot
    canvas.drawCircle(
      Offset(w * 0.05, cy + wave * 0.5),
      3.0,
      Paint()..color = color.withValues(alpha: 0.6 + breath * 0.3),
    );

    final path = Path()
      // Start from left
      ..moveTo(w * 0.05, cy + wave * 0.5)
      // First wave up
      ..cubicTo(
        w * 0.15, cy - 25 + wave,
        w * 0.25, cy + 20 - wave,
        w * 0.38, cy - 10 + wave,
      )
      // The loop — key visual from the mockup
      ..cubicTo(
        w * 0.44, cy - 35 + wave,
        w * 0.54, cy - 40 - wave * 0.5,
        w * 0.54, cy - 15 + wave * 0.5,
      )
      ..cubicTo(
        w * 0.54, cy + 5 - wave * 0.3,
        w * 0.48, cy + 5 + wave * 0.3,
        w * 0.56, cy - 5 - wave * 0.5,
      )
      // Continue flowing right
      ..cubicTo(
        w * 0.65, cy - 20 + wave,
        w * 0.75, cy + 15 - wave,
        w * 0.85, cy - 8 + wave * 0.5,
      )
      // Trail off
      ..cubicTo(
        w * 0.90, cy - 12 - wave * 0.3,
        w * 0.95, cy + 5 + wave * 0.3,
        w, cy - 3,
      );

    // Draw the thread progressively
    final metric = path.computeMetrics().first;
    final drawnPath = metric.extractPath(0, metric.length * draw);

    canvas.drawPath(
      drawnPath,
      Paint()
        ..color = color.withValues(alpha: 0.7 + breath * 0.15)
        ..strokeWidth = thickness
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  /// Journey: thread extends from giver dot outward
  void _paintJourney(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final wave = sin(breath * pi) * 8;

    // Giver dot
    canvas.drawCircle(
      Offset(cx, h * 0.2),
      4.0 + breath * 1.5,
      Paint()..color = AppColors.iris.withValues(alpha: 0.6 + breath * 0.3),
    );

    // Wavy vertical thread
    final path = Path()
      ..moveTo(cx, h * 0.2)
      ..cubicTo(
        cx - 30 + wave, h * 0.35,
        cx + 35 - wave, h * 0.5,
        cx - 15 + wave * 0.5, h * 0.65,
      )
      ..cubicTo(
        cx - 25 - wave * 0.5, h * 0.72,
        cx + 20 + wave, h * 0.78,
        cx, h * 0.85,
      );

    final metric = path.computeMetrics().first;
    final drawnPath = metric.extractPath(0, metric.length * draw);

    canvas.drawPath(
      drawnPath,
      Paint()
        ..color = color.withValues(alpha: 0.5 + breath * 0.2)
        ..strokeWidth = thickness
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Destination dot
    if (draw > 0.9) {
      final fade = ((draw - 0.9) / 0.1).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(cx, h * 0.85),
        4.0 * fade + breath * 1.0,
        Paint()..color = AppColors.mango.withValues(alpha: fade * 0.8),
      );
    }
  }

  /// Tied: two dots connected with a bow
  void _paintTied(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final wave = sin(breath * pi) * 5;

    final dotRadius = 5.0 + breath;

    // Giver dot (iris)
    canvas.drawCircle(
      Offset(cx, h * 0.2),
      dotRadius,
      Paint()..color = AppColors.iris.withValues(alpha: 0.8),
    );

    // Receiver dot (mango)
    canvas.drawCircle(
      Offset(cx, h * 0.8),
      dotRadius * draw,
      Paint()..color = AppColors.mango.withValues(alpha: 0.8 * draw),
    );

    // Bow thread
    final bowOffset = 30.0 + wave;
    final path = Path()
      ..moveTo(cx, h * 0.2)
      ..cubicTo(
        cx - bowOffset, h * 0.4,
        cx + bowOffset, h * 0.6,
        cx, h * 0.8,
      );

    final metric = path.computeMetrics().first;
    final drawnPath = metric.extractPath(0, metric.length * draw);

    canvas.drawPath(
      drawnPath,
      Paint()
        ..color = color.withValues(alpha: 0.6 + breath * 0.15)
        ..strokeWidth = thickness
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Knot at center when tied
    if (draw > 0.95) {
      canvas.drawCircle(
        Offset(cx, h * 0.5),
        3.0 + breath,
        Paint()..color = color.withValues(alpha: 0.3),
      );
    }
  }

  @override
  bool shouldRepaint(_ThreadPainter old) =>
      old.draw != draw || old.breath != breath || old.drift != drift;
}
