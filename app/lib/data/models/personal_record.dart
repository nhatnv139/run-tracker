import 'package:flutter/foundation.dart';

/// Kind of personal record tracked by RunVie.
enum PrKind {
  fastest1k,
  fastest5k,
  fastest10k,
  fastestHalfMarathon,
  fastestMarathon,
  longestRun,
  longestStreak,
  biggestElevation,
  ;

  String get label {
    switch (this) {
      case PrKind.fastest1k:
        return 'Nhanh nhất 1K';
      case PrKind.fastest5k:
        return 'Nhanh nhất 5K';
      case PrKind.fastest10k:
        return 'Nhanh nhất 10K';
      case PrKind.fastestHalfMarathon:
        return 'Nhanh nhất Half Marathon';
      case PrKind.fastestMarathon:
        return 'Nhanh nhất Marathon';
      case PrKind.longestRun:
        return 'Chạy xa nhất';
      case PrKind.longestStreak:
        return 'Streak dài nhất';
      case PrKind.biggestElevation:
        return 'Leo cao nhất';
    }
  }

  /// Distance threshold in meters that a single activity must reach for
  /// the time-based PR to be recorded. `null` for non-distance PRs.
  double? get distanceThresholdMeters {
    switch (this) {
      case PrKind.fastest1k:
        return 1000;
      case PrKind.fastest5k:
        return 5000;
      case PrKind.fastest10k:
        return 10000;
      case PrKind.fastestHalfMarathon:
        return 21097.5;
      case PrKind.fastestMarathon:
        return 42195;
      case PrKind.longestRun:
      case PrKind.longestStreak:
      case PrKind.biggestElevation:
        return null;
    }
  }

  /// `true` if a lower value is better (time-based PRs).
  bool get lowerIsBetter {
    switch (this) {
      case PrKind.fastest1k:
      case PrKind.fastest5k:
      case PrKind.fastest10k:
      case PrKind.fastestHalfMarathon:
      case PrKind.fastestMarathon:
        return true;
      case PrKind.longestRun:
      case PrKind.longestStreak:
      case PrKind.biggestElevation:
        return false;
    }
  }
}

/// A single personal record entry, persisted in Hive.
@immutable
class PersonalRecord {
  const PersonalRecord({
    required this.kind,
    required this.value,
    required this.achievedAt,
    this.activityId,
  });

  final PrKind kind;

  /// Polymorphic value:
  /// - time-based PR (fastest*): seconds (double)
  /// - longest run / biggest elevation: meters (double)
  /// - longest streak: days (double, integer-valued)
  final double value;
  final DateTime achievedAt;
  final int? activityId;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'kind': kind.name,
        'value': value,
        'achievedAt': achievedAt.toIso8601String(),
        'activityId': activityId,
      };

  factory PersonalRecord.fromJson(Map<String, dynamic> json) {
    return PersonalRecord(
      kind: PrKind.values.firstWhere(
        (PrKind k) => k.name == json['kind'],
        orElse: () => PrKind.longestRun,
      ),
      value: (json['value'] as num).toDouble(),
      achievedAt: DateTime.parse(json['achievedAt'] as String),
      activityId: (json['activityId'] as num?)?.toInt(),
    );
  }

  PersonalRecord copyWith({
    PrKind? kind,
    double? value,
    DateTime? achievedAt,
    int? activityId,
  }) {
    return PersonalRecord(
      kind: kind ?? this.kind,
      value: value ?? this.value,
      achievedAt: achievedAt ?? this.achievedAt,
      activityId: activityId ?? this.activityId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PersonalRecord &&
        other.kind == kind &&
        other.value == value &&
        other.achievedAt == achievedAt &&
        other.activityId == activityId;
  }

  @override
  int get hashCode => Object.hash(kind, value, achievedAt, activityId);
}

/// A detected PR that the UI should celebrate.
@immutable
class PrAchievement {
  const PrAchievement({
    required this.kind,
    required this.newValue,
    this.previousValue,
  });

  final PrKind kind;
  final double newValue;
  final double? previousValue;

  bool get isFirstEver => previousValue == null;
}
