import 'package:runvie/data/models/run_session.dart';

/// Tracks 1-km splits as cumulative distance grows.
class SplitTracker {
  SplitTracker();

  int _lastKm = 0;
  Duration _lastKmDuration = Duration.zero;
  double _lastKmElevation = 0.0;
  final List<RunSplit> _splits = <RunSplit>[];

  /// Last kilometre fully crossed (0 if no full km yet).
  int get lastKm => _lastKm;
  List<RunSplit> get splits => List<RunSplit>.unmodifiable(_splits);

  /// Inputs the new cumulative state. Returns any milestones crossed
  /// during this call (typically zero or one, but a single GPS point
  /// could in theory close multiple km if the stream is delayed).
  List<RunSplit> update({
    required double cumulativeMeters,
    required Duration cumulativeMovingTime,
    required double cumulativeElevationGain,
    required DateTime now,
    double? hrAvgForLastKm,
  }) {
    final List<RunSplit> emitted = <RunSplit>[];
    while (cumulativeMeters >= (_lastKm + 1) * 1000) {
      _lastKm += 1;
      final Duration durationForThisKm = cumulativeMovingTime - _lastKmDuration;
      final double elevForThisKm =
          cumulativeElevationGain - _lastKmElevation;
      final double paceSecPerKm = durationForThisKm.inSeconds.toDouble();
      final RunSplit split = RunSplit(
        kmIndex: _lastKm,
        durationSec: durationForThisKm.inSeconds,
        paceSecPerKm: paceSecPerKm,
        completedAt: now,
        hrAvg: hrAvgForLastKm,
        elevationGainM: elevForThisKm,
      );
      _splits.add(split);
      emitted.add(split);
      _lastKmDuration = cumulativeMovingTime;
      _lastKmElevation = cumulativeElevationGain;
    }
    return emitted;
  }

  void reset() {
    _lastKm = 0;
    _lastKmDuration = Duration.zero;
    _lastKmElevation = 0.0;
    _splits.clear();
  }
}
