/// Distance formatting helpers.
class DistanceUtils {
  DistanceUtils._();

  /// Formats meters as km with given decimals (default 2).
  static String formatKm(double meters, {int decimals = 2}) {
    final double km = meters / 1000.0;
    return km.toStringAsFixed(decimals);
  }

  /// Pace seconds-per-km from meters and elapsed.
  static Duration pace(double meters, Duration elapsed) {
    if (meters <= 0) return Duration.zero;
    final double secondsPerKm = elapsed.inSeconds / (meters / 1000.0);
    return Duration(seconds: secondsPerKm.round());
  }
}
