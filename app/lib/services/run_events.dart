import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App-wide event bus for cross-feature run lifecycle signals.
///
/// COORDINATE: this file is shared between the Run-tracking feature (emit
/// side) and the Badges / Coins / Streak / AI Coach features (listen side).
/// The Run-tracking feature is expected to call
/// `ref.read(runEventsBusProvider).emit(...)` whenever an activity finishes
/// uploading; consumers listen via `ref.listen(runEventsStreamProvider)`.
///
/// Keep this file minimal and dependency-free so it is safe for everyone
/// to import.
@immutable
class RunSavedEvent {
  const RunSavedEvent({
    required this.activityId,
    required this.userId,
    required this.distanceMeters,
    required this.durationSec,
    required this.startedAt,
    required this.endedAt,
    this.avgPaceSecPerKm = 0,
    this.elevationGainM = 0,
  });

  final String activityId;
  final String userId;
  final double distanceMeters;
  final int durationSec;
  final DateTime startedAt;
  final DateTime endedAt;
  final double avgPaceSecPerKm;
  final double elevationGainM;

  double get distanceKm => distanceMeters / 1000.0;
}

/// Pub/sub event bus. `broadcast` so multiple listeners (badges + coins +
/// streak) can all react to the same event.
class RunEventsBus {
  RunEventsBus() : _controller = StreamController<RunSavedEvent>.broadcast();

  final StreamController<RunSavedEvent> _controller;

  Stream<RunSavedEvent> get stream => _controller.stream;

  void emit(RunSavedEvent event) {
    if (_controller.isClosed) return;
    _controller.add(event);
  }

  Future<void> dispose() => _controller.close();
}

final Provider<RunEventsBus> runEventsBusProvider = Provider<RunEventsBus>((
  Ref ref,
) {
  final RunEventsBus bus = RunEventsBus();
  ref.onDispose(bus.dispose);
  return bus;
});

final StreamProvider<RunSavedEvent> runEventsStreamProvider =
    StreamProvider<RunSavedEvent>((Ref ref) {
  return ref.watch(runEventsBusProvider).stream;
});
