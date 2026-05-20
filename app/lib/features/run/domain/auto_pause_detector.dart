import 'dart:async';
import 'dart:math' as math;

/// Detects auto-pause and auto-resume transitions.
///
/// Auto-pause: speed < 0.5 m/s AND |accel - g| < 0.05 g for 8 s continuously.
/// Auto-resume: speed > 1.5 m/s for 3 s continuously.
class AutoPauseDetector {
  AutoPauseDetector({
    this.pauseSpeedThreshold = 0.5,
    this.pauseDuration = const Duration(seconds: 8),
    this.resumeSpeedThreshold = 1.5,
    this.resumeDuration = const Duration(seconds: 3),
    this.accelStillThresholdG = 0.05,
  });

  final double pauseSpeedThreshold; // m/s
  final Duration pauseDuration;
  final double resumeSpeedThreshold; // m/s
  final Duration resumeDuration;
  final double accelStillThresholdG;

  static const double _gravity = 9.80665;

  bool _isAutoPaused = false;
  DateTime? _slowSince;
  DateTime? _fastSince;
  bool _accelStill = true;

  bool get isAutoPaused => _isAutoPaused;

  final StreamController<AutoPauseTransition> _transitions =
      StreamController<AutoPauseTransition>.broadcast();
  Stream<AutoPauseTransition> get transitions => _transitions.stream;

  /// Feed an accelerometer sample (x, y, z in m/s^2). The detector
  /// classifies the device as "still" when |a| - g is within
  /// `accelStillThresholdG`.
  void onAccelerometer(double x, double y, double z) {
    final double mag = math.sqrt(x * x + y * y + z * z);
    final double deviation = (mag - _gravity).abs() / _gravity;
    _accelStill = deviation < accelStillThresholdG;
  }

  /// Feed a speed sample (m/s) at the supplied timestamp.
  /// Returns the transition that occurred at this sample, if any.
  AutoPauseTransition? onSpeed(double speedMps, DateTime now) {
    AutoPauseTransition? transition;
    if (!_isAutoPaused) {
      if (speedMps < pauseSpeedThreshold && _accelStill) {
        _slowSince ??= now;
        if (now.difference(_slowSince!) >= pauseDuration) {
          _isAutoPaused = true;
          _slowSince = null;
          _fastSince = null;
          transition = AutoPauseTransition.pause;
        }
      } else {
        _slowSince = null;
      }
    } else {
      if (speedMps > resumeSpeedThreshold) {
        _fastSince ??= now;
        if (now.difference(_fastSince!) >= resumeDuration) {
          _isAutoPaused = false;
          _slowSince = null;
          _fastSince = null;
          transition = AutoPauseTransition.resume;
        }
      } else {
        _fastSince = null;
      }
    }

    if (transition != null && !_transitions.isClosed) {
      _transitions.add(transition);
    }
    return transition;
  }

  void reset() {
    _isAutoPaused = false;
    _slowSince = null;
    _fastSince = null;
    _accelStill = true;
  }

  Future<void> dispose() => _transitions.close();
}

enum AutoPauseTransition { pause, resume }
