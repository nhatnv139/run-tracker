import 'dart:math' as math;

/// Geographic math helpers — kept lightweight & dependency-free so they
/// can be exercised in pure-Dart unit tests.
class GeoMath {
  GeoMath._();

  static const double earthRadiusMeters = 6371000.0;

  /// Great-circle distance between two WGS84 coordinates, in meters.
  static double haversine(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final double phi1 = lat1 * math.pi / 180.0;
    final double phi2 = lat2 * math.pi / 180.0;
    final double dPhi = (lat2 - lat1) * math.pi / 180.0;
    final double dLambda = (lon2 - lon1) * math.pi / 180.0;
    final double a = math.sin(dPhi / 2) * math.sin(dPhi / 2) +
        math.cos(phi1) *
            math.cos(phi2) *
            math.sin(dLambda / 2) *
            math.sin(dLambda / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }
}
