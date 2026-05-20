import 'package:flutter/foundation.dart';

/// High-level state machine for an active run session.
enum RunSessionStatus {
  idle,
  preparing,
  running,
  paused,
  autoPaused,
  finishing,
  saved,
  discarded,
}

/// Terrain affects MET-based calorie estimate.
enum RunTerrain { road, trail, treadmill, track }

extension RunTerrainSerde on RunTerrain {
  String get id => name;
  static RunTerrain fromId(String s) =>
      RunTerrain.values.firstWhere((RunTerrain t) => t.name == s,
          orElse: () => RunTerrain.road);
}

/// Single point in the recorded GPS trace (post-filter).
@immutable
class TrackSample {
  const TrackSample({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.altitude,
    this.speed,
    this.isPaused = false,
  });

  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double accuracy;
  final double? altitude;
  final double? speed;
  final bool isPaused;

  TrackSample copyWith({
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    bool? isPaused,
  }) {
    return TrackSample(
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}

/// One completed kilometer split.
@immutable
class RunSplit {
  const RunSplit({
    required this.kmIndex,
    required this.durationSec,
    required this.paceSecPerKm,
    required this.completedAt,
    this.hrAvg,
    this.elevationGainM = 0,
  });

  final int kmIndex;
  final int durationSec;
  final double paceSecPerKm;
  final double? hrAvg;
  final double elevationGainM;
  final DateTime completedAt;
}

/// Snapshot of the live run state — exposed by Riverpod.
@immutable
class RunSessionState {
  const RunSessionState({
    this.status = RunSessionStatus.idle,
    this.runId,
    this.startedAt,
    this.distanceMeters = 0,
    this.elapsed = Duration.zero,
    this.movingTime = Duration.zero,
    this.calories = 0,
    this.currentPace = Duration.zero,
    this.avgPace = Duration.zero,
    this.elevationGainM = 0,
    this.splits = const <RunSplit>[],
    this.lastKmMilestone = 0,
    this.terrain = RunTerrain.road,
    this.gpsHasFix = false,
    this.errorMessage,
  });

  final RunSessionStatus status;
  final int? runId;
  final DateTime? startedAt;
  final double distanceMeters;
  final Duration elapsed;
  final Duration movingTime;
  final double calories;
  final Duration currentPace;
  final Duration avgPace;
  final double elevationGainM;
  final List<RunSplit> splits;
  final int lastKmMilestone;
  final RunTerrain terrain;
  final bool gpsHasFix;
  final String? errorMessage;

  double get distanceKm => distanceMeters / 1000.0;

  bool get isActive =>
      status == RunSessionStatus.running ||
      status == RunSessionStatus.paused ||
      status == RunSessionStatus.autoPaused;

  bool get isMoving => status == RunSessionStatus.running;

  RunSessionState copyWith({
    RunSessionStatus? status,
    int? runId,
    DateTime? startedAt,
    double? distanceMeters,
    Duration? elapsed,
    Duration? movingTime,
    double? calories,
    Duration? currentPace,
    Duration? avgPace,
    double? elevationGainM,
    List<RunSplit>? splits,
    int? lastKmMilestone,
    RunTerrain? terrain,
    bool? gpsHasFix,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RunSessionState(
      status: status ?? this.status,
      runId: runId ?? this.runId,
      startedAt: startedAt ?? this.startedAt,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      elapsed: elapsed ?? this.elapsed,
      movingTime: movingTime ?? this.movingTime,
      calories: calories ?? this.calories,
      currentPace: currentPace ?? this.currentPace,
      avgPace: avgPace ?? this.avgPace,
      elevationGainM: elevationGainM ?? this.elevationGainM,
      splits: splits ?? this.splits,
      lastKmMilestone: lastKmMilestone ?? this.lastKmMilestone,
      terrain: terrain ?? this.terrain,
      gpsHasFix: gpsHasFix ?? this.gpsHasFix,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Domain event emitted to other services (voice coach, sync queue).
@immutable
sealed class RunSessionEvent {
  const RunSessionEvent();
}

class KmMilestoneEvent extends RunSessionEvent {
  const KmMilestoneEvent({
    required this.km,
    required this.elapsed,
    required this.paceLastKm,
  });
  final int km;
  final Duration elapsed;
  final Duration paceLastKm;
}

class AutoPauseEvent extends RunSessionEvent {
  const AutoPauseEvent();
}

class AutoResumeEvent extends RunSessionEvent {
  const AutoResumeEvent();
}

class ActivitySavedEvent extends RunSessionEvent {
  const ActivitySavedEvent({required this.runId});
  final int runId;
}

class ActivityDiscardedEvent extends RunSessionEvent {
  const ActivityDiscardedEvent({required this.runId});
  final int runId;
}
