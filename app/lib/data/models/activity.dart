import 'package:flutter/foundation.dart';

/// Type of activity captured by the user.
enum ActivityType {
  run,
  walk,
  treadmill,
  trail,
  ;

  String get label {
    switch (this) {
      case ActivityType.run:
        return 'Chạy bộ';
      case ActivityType.walk:
        return 'Đi bộ';
      case ActivityType.treadmill:
        return 'Máy chạy';
      case ActivityType.trail:
        return 'Trail';
    }
  }

  static ActivityType fromName(String? name) {
    return ActivityType.values.firstWhere(
      (ActivityType t) => t.name == name,
      orElse: () => ActivityType.run,
    );
  }
}

/// Sync state of an activity with the cloud backend.
enum ActivitySyncStatus {
  synced,
  pending,
  failed,
  ;

  static ActivitySyncStatus fromName(String? name) {
    return ActivitySyncStatus.values.firstWhere(
      (ActivitySyncStatus s) => s.name == name,
      orElse: () => ActivitySyncStatus.pending,
    );
  }
}

/// A single split (1 km segment) of a run.
@immutable
class ActivitySplit {
  const ActivitySplit({
    required this.km,
    required this.duration,
    required this.elevationGain,
    this.avgHr,
  });

  final int km;
  final Duration duration;
  final double elevationGain;
  final int? avgHr;

  /// Pace seconds per km.
  int get paceSecPerKm => duration.inSeconds;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'km': km,
        'durationSec': duration.inSeconds,
        'elevationGain': elevationGain,
        'avgHr': avgHr,
      };

  factory ActivitySplit.fromJson(Map<String, dynamic> json) {
    return ActivitySplit(
      km: (json['km'] as num).toInt(),
      duration: Duration(seconds: (json['durationSec'] as num).toInt()),
      elevationGain: (json['elevationGain'] as num).toDouble(),
      avgHr: (json['avgHr'] as num?)?.toInt(),
    );
  }
}

/// A weather snapshot at the start of the activity.
@immutable
class WeatherSnapshot {
  const WeatherSnapshot({
    required this.tempC,
    required this.humidity,
    required this.condition,
    this.windKph,
  });

  final double tempC;
  final int humidity;
  final String condition;
  final double? windKph;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'tempC': tempC,
        'humidity': humidity,
        'condition': condition,
        'windKph': windKph,
      };

  factory WeatherSnapshot.fromJson(Map<String, dynamic> json) {
    return WeatherSnapshot(
      tempC: (json['tempC'] as num).toDouble(),
      humidity: (json['humidity'] as num).toInt(),
      condition: json['condition'] as String,
      windKph: (json['windKph'] as num?)?.toDouble(),
    );
  }
}

/// A completed activity (run/walk/etc).
///
/// Plain immutable class — no Freezed needed; the rest of the codebase
/// uses the same pattern (see [RunSessionState]).
@immutable
class Activity {
  const Activity({
    required this.id,
    required this.type,
    required this.startedAt,
    required this.endedAt,
    required this.distanceMeters,
    required this.duration,
    required this.avgPaceSecPerKm,
    required this.calories,
    required this.syncStatus,
    this.remoteId,
    this.elevationGainM = 0,
    this.avgHr,
    this.maxHr,
    this.encodedPolyline,
    this.splits = const <ActivitySplit>[],
    this.hrZoneSeconds = const <int>[0, 0, 0, 0, 0],
    this.weather,
    this.rpe,
    this.kudos = 0,
    this.note,
  });

  final int id;
  final String? remoteId;
  final ActivityType type;
  final DateTime startedAt;
  final DateTime endedAt;
  final double distanceMeters;
  final Duration duration;
  final double avgPaceSecPerKm;
  final double calories;
  final double elevationGainM;
  final int? avgHr;
  final int? maxHr;
  final String? encodedPolyline;
  final List<ActivitySplit> splits;

  /// Seconds spent in HR zones 1..5 (length 5).
  final List<int> hrZoneSeconds;

  final WeatherSnapshot? weather;

  /// Rate of Perceived Exertion (1..10).
  final int? rpe;

  final int kudos;
  final String? note;
  final ActivitySyncStatus syncStatus;

  double get distanceKm => distanceMeters / 1000.0;

  /// Local date (year/month/day) — used for heatmap bucketing.
  DateTime get localDate =>
      DateTime(startedAt.year, startedAt.month, startedAt.day);

  Activity copyWith({
    int? id,
    String? remoteId,
    ActivityType? type,
    DateTime? startedAt,
    DateTime? endedAt,
    double? distanceMeters,
    Duration? duration,
    double? avgPaceSecPerKm,
    double? calories,
    double? elevationGainM,
    int? avgHr,
    int? maxHr,
    String? encodedPolyline,
    List<ActivitySplit>? splits,
    List<int>? hrZoneSeconds,
    WeatherSnapshot? weather,
    int? rpe,
    int? kudos,
    String? note,
    ActivitySyncStatus? syncStatus,
  }) {
    return Activity(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      type: type ?? this.type,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      duration: duration ?? this.duration,
      avgPaceSecPerKm: avgPaceSecPerKm ?? this.avgPaceSecPerKm,
      calories: calories ?? this.calories,
      elevationGainM: elevationGainM ?? this.elevationGainM,
      avgHr: avgHr ?? this.avgHr,
      maxHr: maxHr ?? this.maxHr,
      encodedPolyline: encodedPolyline ?? this.encodedPolyline,
      splits: splits ?? this.splits,
      hrZoneSeconds: hrZoneSeconds ?? this.hrZoneSeconds,
      weather: weather ?? this.weather,
      rpe: rpe ?? this.rpe,
      kudos: kudos ?? this.kudos,
      note: note ?? this.note,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Activity &&
        other.id == id &&
        other.startedAt == startedAt &&
        other.distanceMeters == distanceMeters &&
        other.duration == duration;
  }

  @override
  int get hashCode => Object.hash(id, startedAt, distanceMeters, duration);
}
