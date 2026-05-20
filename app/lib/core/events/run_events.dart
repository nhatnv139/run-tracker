import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cross-feature run event bus.
///
/// The run-tracking feature emits [RunEvent]s here; the voice coach
/// subscribes to translate them into TTS cues. Other features may also
/// subscribe (e.g. badges, social).
///
/// The contract is intentionally a *thin* discriminated union: the
/// emitter does not know who listens, and listeners do not need to
/// import anything from the `run` feature.
enum RunEventType {
  start,
  pause,
  resume,
  stop,
  kmMilestone,
  paceFast,
  paceSlow,
  zoneChange,
  weatherWarning,
  motivation25,
  motivation50,
  motivation75,
  streakMilestone,
}

@immutable
class RunEvent {
  const RunEvent({
    required this.type,
    this.km,
    this.paceSecPerKm,
    this.targetPaceSecPerKm,
    this.hr,
    this.zone,
    this.distanceMeters,
    this.durationSec,
    this.tempC,
    this.aqi,
    this.streakDays,
    this.extra,
  });

  final RunEventType type;
  final int? km;
  final int? paceSecPerKm;
  final int? targetPaceSecPerKm;
  final int? hr;
  final int? zone;
  final double? distanceMeters;
  final int? durationSec;
  final double? tempC;
  final int? aqi;
  final int? streakDays;
  final Map<String, String>? extra;

  /// Build the template substitution map used by the voice coach.
  Map<String, String> toSubstitutions() {
    final Map<String, String> m = <String, String>{
      if (km != null) 'km': '$km',
      if (km != null) 'km_plus_one': '${km! + 1}',
      if (paceSecPerKm != null) 'pace': _formatPace(paceSecPerKm!),
      if (targetPaceSecPerKm != null)
        'target_pace': _formatPace(targetPaceSecPerKm!),
      if (hr != null) 'hr': '$hr',
      if (zone != null) 'zone': '$zone',
      if (distanceMeters != null)
        'distance': (distanceMeters! / 1000).toStringAsFixed(2),
      if (durationSec != null) 'duration': _formatDuration(durationSec!),
      if (tempC != null) 'temp': tempC!.toStringAsFixed(0),
      if (aqi != null) 'aqi': '$aqi',
      if (streakDays != null) 'streak': '$streakDays',
    };
    if (extra != null) m.addAll(extra!);
    return m;
  }

  static String _formatPace(int secPerKm) {
    final int m = secPerKm ~/ 60;
    final int s = secPerKm % 60;
    return "$m phút ${s.toString().padLeft(2, '0')} giây";
  }

  static String _formatDuration(int sec) {
    final int h = sec ~/ 3600;
    final int m = (sec % 3600) ~/ 60;
    final int s = sec % 60;
    if (h > 0) return '$h giờ $m phút';
    return '$m phút $s giây';
  }
}

/// Singleton-style broadcast bus. Use [runEventBusProvider] in widgets.
class RunEventBus {
  RunEventBus() : _controller = StreamController<RunEvent>.broadcast();

  final StreamController<RunEvent> _controller;

  Stream<RunEvent> get stream => _controller.stream;

  void emit(RunEvent event) {
    if (_controller.isClosed) return;
    _controller.add(event);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

final Provider<RunEventBus> runEventBusProvider =
    Provider<RunEventBus>((Ref ref) {
  final RunEventBus bus = RunEventBus();
  ref.onDispose(bus.dispose);
  return bus;
});

/// Convenience stream provider — listeners watch this.
final StreamProvider<RunEvent> runEventStreamProvider =
    StreamProvider<RunEvent>((Ref ref) {
  return ref.watch(runEventBusProvider).stream;
});
