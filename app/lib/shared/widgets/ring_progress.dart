import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:runvie/core/theme/colors.dart';

/// Circular ring progress with aurora gradient stroke.
class RingProgress extends StatelessWidget {
  const RingProgress({
    required this.progress,
    this.size = 200,
    this.strokeWidth = 14,
    this.gradient = AuroraColors.auroraGradient,
    this.trackColor,
    this.child,
    super.key,
  });

  /// 0.0 - 1.0
  final double progress;
  final double size;
  final double strokeWidth;
  final List<Color> gradient;
  final Color? trackColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress.clamp(0.0, 1.0),
          strokeWidth: strokeWidth,
          gradient: gradient,
          trackColor: trackColor ??
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradient,
    required this.trackColor,
  });

  final double progress;
  final double strokeWidth;
  final List<Color> gradient;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.shortestSide - strokeWidth) / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;

    final Paint progressPaint = Paint()
      ..shader = SweepGradient(
        colors: gradient,
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress ||
      old.strokeWidth != strokeWidth ||
      old.trackColor != trackColor;
}
