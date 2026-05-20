import 'package:runvie/data/models/activity.dart';
import 'package:runvie/shared/utils/polyline_codec.dart';

/// Builds a Strava-compatible GPX 1.1 document from an [Activity].
class GpxExporter {
  GpxExporter._();

  static String build(Activity activity) {
    final List<LatLng> points = activity.encodedPolyline != null
        ? PolylineCodec.decode(activity.encodedPolyline!)
        : const <LatLng>[];

    final String startIso = activity.startedAt.toUtc().toIso8601String();
    final StringBuffer buf = StringBuffer()
      ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
      ..writeln(
        '<gpx version="1.1" creator="RunVie" '
        'xmlns="http://www.topografix.com/GPX/1/1" '
        'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
        'xsi:schemaLocation="http://www.topografix.com/GPX/1/1 '
        'http://www.topografix.com/GPX/1/1/gpx.xsd">',
      )
      ..writeln('  <metadata>')
      ..writeln('    <time>$startIso</time>')
      ..writeln('  </metadata>')
      ..writeln('  <trk>')
      ..writeln('    <name>${_escape(activity.type.label)} ${_dateLabel(activity.startedAt)}</name>')
      ..writeln('    <type>${activity.type.name}</type>')
      ..writeln('    <trkseg>');

    if (points.isEmpty) {
      // GPX is still valid with empty trkseg.
    } else {
      final Duration total = activity.duration;
      final int n = points.length;
      for (int i = 0; i < n; i++) {
        final LatLng p = points[i];
        final double frac = n > 1 ? i / (n - 1) : 0;
        final DateTime t = activity.startedAt.add(
          Duration(milliseconds: (total.inMilliseconds * frac).round()),
        );
        buf
          ..writeln(
              '      <trkpt lat="${p.lat.toStringAsFixed(6)}" lon="${p.lng.toStringAsFixed(6)}">')
          ..writeln('        <time>${t.toUtc().toIso8601String()}</time>')
          ..writeln('      </trkpt>');
      }
    }

    buf
      ..writeln('    </trkseg>')
      ..writeln('  </trk>')
      ..writeln('</gpx>');

    return buf.toString();
  }

  static String _escape(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');

  static String _dateLabel(DateTime when) {
    final String y = when.year.toString();
    final String m = when.month.toString().padLeft(2, '0');
    final String d = when.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
