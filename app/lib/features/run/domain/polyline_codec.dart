import 'dart:math' as math;

/// Google Encoded Polyline Algorithm Format (precision 5).
/// Reference: https://developers.google.com/maps/documentation/utilities/polylinealgorithm
class PolylineCodec {
  PolylineCodec._();

  /// Encodes a sequence of (lat, lon) pairs into a compact ASCII string.
  static String encode(
    List<List<double>> points, {
    int precision = 5,
  }) {
    final double factor = math.pow(10, precision).toDouble();
    final StringBuffer out = StringBuffer();
    int prevLat = 0;
    int prevLon = 0;

    for (final List<double> p in points) {
      final int lat = (p[0] * factor).round();
      final int lon = (p[1] * factor).round();
      _encodeValue(lat - prevLat, out);
      _encodeValue(lon - prevLon, out);
      prevLat = lat;
      prevLon = lon;
    }
    return out.toString();
  }

  static void _encodeValue(int value, StringBuffer out) {
    int v = value < 0 ? ~(value << 1) : value << 1;
    while (v >= 0x20) {
      out.writeCharCode((0x20 | (v & 0x1f)) + 63);
      v >>= 5;
    }
    out.writeCharCode(v + 63);
  }

  /// Decodes a polyline string back into (lat, lon) pairs.
  static List<List<double>> decode(
    String encoded, {
    int precision = 5,
  }) {
    final double factor = math.pow(10, precision).toDouble();
    final List<List<double>> points = <List<double>>[];
    int index = 0;
    int lat = 0;
    int lon = 0;
    final int length = encoded.length;

    while (index < length) {
      final List<int> latRes = _decodeValue(encoded, index);
      lat += latRes[0];
      index = latRes[1];

      final List<int> lonRes = _decodeValue(encoded, index);
      lon += lonRes[0];
      index = lonRes[1];

      points.add(<double>[lat / factor, lon / factor]);
    }
    return points;
  }

  static List<int> _decodeValue(String encoded, int index) {
    int result = 0;
    int shift = 0;
    int b;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    final int delta = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
    return <int>[delta, index];
  }
}
