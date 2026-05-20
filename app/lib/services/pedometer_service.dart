import 'dart:async';

import 'package:pedometer/pedometer.dart';

import 'package:runvie/data/models/daily_step.dart';
import 'package:runvie/data/repositories/steps_repository.dart';

/// Wraps the native step counter.
///
/// Platform notes:
/// - iOS uses `CMPedometer` (M-coprocessor counts natively, low-power
///   continuous sampling — typically <5 mAh/day on modern hardware).
/// - Android uses `Sensor.TYPE_STEP_COUNTER` — a cumulative counter
///   since last device boot, also implemented in low-power hardware on
///   most devices.
///
/// The native counters are **monotonic since boot/reset**. To derive
/// "steps today" the service tracks a per-day baseline: on the first
/// tick of a calendar day it records the raw native value, and every
/// subsequent tick subtracts it. If the device reboots (cumulative
/// counter drops below the baseline) we transparently re-baseline.
class PedometerService {
  PedometerService({
    StepsRepository? repository,
    Stream<StepCount>? stepStreamOverride,
    Stream<PedestrianStatus>? statusStreamOverride,
    DateTime Function()? clock,
  })  : _repo = repository,
        _stepStreamOverride = stepStreamOverride,
        _statusStreamOverride = statusStreamOverride,
        _clock = clock ?? DateTime.now;

  /// Default singleton used by production code paths. Tests should
  /// instantiate their own [PedometerService] via the constructor.
  static final PedometerService instance = PedometerService();

  final StepsRepository? _repo;
  final Stream<StepCount>? _stepStreamOverride;
  final Stream<PedestrianStatus>? _statusStreamOverride;
  final DateTime Function() _clock;

  StreamSubscription<StepCount>? _stepSub;
  StreamSubscription<PedestrianStatus>? _statusSub;

  /// Raw cumulative step count at the start of the current local day.
  int? _baselineSteps;
  DateTime? _baselineDay;
  int _stepsToday = 0;
  String _status = 'unknown';
  double _weightKg = 70;

  final StreamController<int> _stepController =
      StreamController<int>.broadcast();
  final StreamController<String> _statusController =
      StreamController<String>.broadcast();

  /// Emits "steps today" as a continuous integer.
  Stream<int> get stepStream => _stepController.stream;

  /// Emits `walking` / `stopped` / `unknown`.
  Stream<String> get statusStream => _statusController.stream;

  int get stepsToday => _stepsToday;
  String get currentStatus => _status;

  /// Optionally update user weight for calorie estimates persisted via
  /// [StepsRepository.recordTick].
  void setUserWeight(double kg) {
    if (kg > 0) _weightKg = kg;
  }

  Future<void> start() async {
    await stop();
    final Stream<StepCount> steps =
        _stepStreamOverride ?? Pedometer.stepCountStream;
    final Stream<PedestrianStatus> statuses =
        _statusStreamOverride ?? Pedometer.pedestrianStatusStream;

    _stepSub = steps.listen(
      _onStep,
      onError: _stepController.addError,
    );
    _statusSub = statuses.listen(
      _onStatus,
      onError: _statusController.addError,
    );
  }

  Future<void> stop() async {
    await _stepSub?.cancel();
    await _statusSub?.cancel();
    _stepSub = null;
    _statusSub = null;
  }

  /// Manually fed for tests + background isolate without exposing the
  /// underlying pedometer plugin.
  Future<void> ingestRawCount(int raw, {DateTime? when}) async {
    final DateTime ts = when ?? _clock();
    _applyRaw(raw, ts);
    if (_repo != null) {
      await _repo.recordTick(
        totalStepsToday: _stepsToday,
        weightKg: _weightKg,
      );
    }
  }

  void _onStep(StepCount event) {
    final DateTime ts = event.timeStamp;
    _applyRaw(event.steps, ts);
    if (_repo != null) {
      // Fire-and-forget on the tick path; failures shouldn't kill stream.
      unawaited(_repo.recordTick(
        totalStepsToday: _stepsToday,
        weightKg: _weightKg,
      ));
    }
  }

  void _applyRaw(int raw, DateTime when) {
    final DateTime today = DateTime(when.year, when.month, when.day);
    if (_baselineDay == null || _baselineDay != today) {
      // New day (or first ever tick): rebaseline.
      _baselineDay = today;
      _baselineSteps = raw;
      _stepsToday = 0;
    } else if (_baselineSteps == null || raw < _baselineSteps!) {
      // Counter rolled (device reboot). Rebaseline mid-day; preserve
      // any steps we already counted today.
      _baselineSteps = raw - _stepsToday;
      if (_baselineSteps! < 0) _baselineSteps = 0;
    } else {
      _stepsToday = raw - _baselineSteps!;
    }
    _stepController.add(_stepsToday);
  }

  void _onStatus(PedestrianStatus event) {
    _status = event.status;
    _statusController.add(event.status);
  }

  Future<void> dispose() async {
    await stop();
    await _stepController.close();
    await _statusController.close();
  }
}

/// Lightweight helper for surfacing the pedometer-derived
/// [DailyStep] without coupling the service to the repository's
/// concrete Drift dependency in pure-Dart contexts (tests, isolates).
class StepTick {
  const StepTick({
    required this.totalToday,
    required this.timestamp,
    this.status = 'unknown',
  });

  final int totalToday;
  final DateTime timestamp;
  final String status;

  DailyStep toDailyStep({
    DailyStepSource source = DailyStepSource.pedometer,
    double weightKg = 70,
  }) {
    return DailyStep(
      date: DateTime(timestamp.year, timestamp.month, timestamp.day),
      steps: totalToday,
      distanceMeters: totalToday * 0.762,
      calories: totalToday * 0.04 * (weightKg / 70).clamp(0.6, 1.6),
      source: source,
      updatedAt: timestamp,
    );
  }
}
