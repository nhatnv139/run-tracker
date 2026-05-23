import 'package:flutter/material.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/shared/utils/polyline_codec.dart';

/// Renders a tiny normalized silhouette of an encoded polyline.
class RouteThumbnail extends StatelessWidget {
  const RouteThumbnail({
    required this.encoded,
    this.size = const Size(80, 40),
    this.color = AuroraColors.coralPrimary,
    this.stroke = 1.8,
    super.key,
  });

  final String? encoded;
  final Size size;
  final Color color;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    final Color bg = Theme.of(context).colorScheme.surfaceContainerHighest;
    final bool stretchWidth = size.width == double.infinity;
    final bool stretchHeight = size.height == double.infinity;
    if (encoded == null || encoded!.isEmpty) {
      return Container(
        width: stretchWidth ? null : size.width,
        height: stretchHeight ? null : size.height,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.timeline_rounded,
            size: 16, color: color.withValues(alpha: 0.5)),
      );
    }
    final List<LatLng> points = PolylineCodec.decode(encoded!);
    final Widget content = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final double w = stretchWidth ? c.maxWidth : size.width;
        final double h = stretchHeight ? c.maxHeight : size.height;
        return CustomPaint(
          size: Size(w, h),
          painter: _RoutePainter(points, color, stroke),
        );
      },
    );
    return Container(
      width: stretchWidth ? null : size.width,
      height: stretchHeight ? null : size.height,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: content,
    );
  }
}

class _RoutePainter extends CustomPainter {
  _RoutePainter(this.points, this.color, this.stroke);

  final List<LatLng> points;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    double minLat = points.first.lat;
    double maxLat = points.first.lat;
    double minLng = points.first.lng;
    double maxLng = points.first.lng;
    for (final LatLng p in points) {
      if (p.lat < minLat) minLat = p.lat;
      if (p.lat > maxLat) maxLat = p.lat;
      if (p.lng < minLng) minLng = p.lng;
      if (p.lng > maxLng) maxLng = p.lng;
    }
    final double dLat = (maxLat - minLat).abs();
    final double dLng = (maxLng - minLng).abs();
    final double pad = 3;
    final double w = size.width - 2 * pad;
    final double h = size.height - 2 * pad;
    final double scale = dLat == 0 && dLng == 0
        ? 1
        : (dLng == 0 ? h / dLat : (dLat == 0 ? w / dLng : (w / dLng).clamp(0.0, h / (dLat == 0 ? 1 : dLat))));
    Offset project(LatLng p) {
      final double x = pad + (p.lng - minLng) * (dLng == 0 ? 0 : w / dLng);
      final double y = pad + (maxLat - p.lat) * (dLat == 0 ? 0 : h / dLat);
      return Offset(x, y);
    }

    final Path path = Path();
    final Offset first = project(points.first);
    path.moveTo(first.dx, first.dy);
    for (int i = 1; i < points.length; i++) {
      final Offset o = project(points[i]);
      path.lineTo(o.dx, o.dy);
    }
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);
    // Mark scale read to satisfy the analyzer when it isn't otherwise used.
    assert(scale >= 0);
  }

  @override
  bool shouldRepaint(covariant _RoutePainter old) =>
      old.points != points || old.color != color || old.stroke != stroke;
}
