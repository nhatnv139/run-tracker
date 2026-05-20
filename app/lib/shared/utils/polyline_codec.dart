import 'package:flutter/foundation.dart';

/// Google encoded polyline algorithm (precision 5).
///
/// Pure-Dart implementation — used both by the activity map preview and
/// the GPX export.
class PolylineCodec {
  PolylineCodec._();

  static String encode(List<LatLng> points) {
    final StringBuffer buf = StringBuffer();
    int prevLat = 0;
    int prevLng = 0;
    for (final LatLng p in points) {
      final int lat = (p.lat * 1e5).round();
      final int lng = (p.lng * 1e5).round();
      _encodeValue(lat - prevLat, buf);
      _encodeValue(lng - prevLng, buf);
      prevLat = lat;
      prevLng = lng;
    }
    return buf.toString();
  }

  static List<LatLng> decode(String encoded) {
    final List<LatLng> out = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;
    final int len = encoded.length;
    while (index < len) {
      final _DecodedValue dLat = _decodeValue(encoded, index);
      lat += dLat.value;
      index = dLat.next;
      final _DecodedValue dLng = _decodeValue(encoded, index);
      lng += dLng.value;
      index = dLng.next;
      out.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return out;
  }

  static void _encodeValue(int v, StringBuffer buf) {
    int shifted = v < 0 ? ~(v << 1) : v << 1;
    while (shifted >= 0x20) {
      buf.writeCharCode((0x20 | (shifted & 0x1f)) + 63);
      shifted >>= 5;
    }
    buf.writeCharCode(shifted + 63);
  }

  static _DecodedValue _decodeValue(String s, int start) {
    int result = 0;
    int shift = 0;
    int b;
    int index = start;
    do {
      b = s.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    final int decoded = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    return _DecodedValue(decoded, index);
  }
}

@immutable
class LatLng {
  const LatLng(this.lat, this.lng);
  final double lat;
  final double lng;

  @override
  bool operator ==(Object other) =>
      other is LatLng && other.lat == lat && other.lng == lng;

  @override
  int get hashCode => Object.hash(lat, lng);
}

class _DecodedValue {
  _DecodedValue(this.value, this.next);
  final int value;
  final int next;
}
