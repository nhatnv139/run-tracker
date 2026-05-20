import 'dart:collection';

/// Rolling-window pace calculator.
///
/// Accumulates `(timestamp, cumulativeDistanceMeters)` samples and reports
/// the pace over the last [window] (default 30 s). Pace is reported in
/// seconds per kilometre.
class PaceCalculator {
  PaceCalculator({this.window = const Duration(seconds: 30)});

  final Duration window;
  final Queue<_PacePoint> _points = Queue<_PacePoint>();

  /// Adds a sample. Multiple calls per second are fine.
  void addSample(DateTime time, double cumulativeMeters) {
    _points.addLast(_PacePoint(time, cumulativeMeters));
    _trim(time);
  }

  void _trim(DateTime now) {
    final DateTime cutoff = now.subtract(window);
    while (_points.length > 1 && _points.first.time.isBefore(cutoff)) {
      _points.removeFirst();
    }
  }

  /// Current pace in seconds per kilometre. Returns `Duration.zero` while
  /// not enough data has accumulated.
  Duration currentPace() {
    if (_points.length < 2) return Duration.zero;
    final _PacePoint first = _points.first;
    final _PacePoint last = _points.last;
    final double distM = last.cumulativeMeters - first.cumulativeMeters;
    final Duration dt = last.time.difference(first.time);
    if (distM < 5.0 || dt.inMilliseconds < 1000) return Duration.zero;
    final double seconds = dt.inMilliseconds / 1000.0;
    final double secPerKm = seconds / (distM / 1000.0);
    return Duration(milliseconds: (secPerKm * 1000).round());
  }

  /// Average pace from the very first observed sample to the most recent.
  Duration averagePace() {
    if (_points.length < 2) return Duration.zero;
    final _PacePoint first = _points.first;
    final _PacePoint last = _points.last;
    final double distM = last.cumulativeMeters - first.cumulativeMeters;
    final Duration dt = last.time.difference(first.time);
    if (distM <= 0 || dt.inMilliseconds <= 0) return Duration.zero;
    final double seconds = dt.inMilliseconds / 1000.0;
    final double secPerKm = seconds / (distM / 1000.0);
    return Duration(milliseconds: (secPerKm * 1000).round());
  }

  void reset() => _points.clear();
}

class _PacePoint {
  _PacePoint(this.time, this.cumulativeMeters);
  final DateTime time;
  final double cumulativeMeters;
}
