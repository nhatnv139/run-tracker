import 'package:flutter/material.dart';

import 'package:runvie/core/theme/colors.dart';

enum WorkoutType {
  rest,
  walk,
  easyRun,
  intervals,
  tempo,
  longRun,
  race,
}

extension WorkoutTypeX on WorkoutType {
  String get label {
    switch (this) {
      case WorkoutType.rest:
        return 'Nghỉ';
      case WorkoutType.walk:
        return 'Đi bộ';
      case WorkoutType.easyRun:
        return 'Chạy nhẹ';
      case WorkoutType.intervals:
        return 'Interval';
      case WorkoutType.tempo:
        return 'Tempo';
      case WorkoutType.longRun:
        return 'Chạy dài';
      case WorkoutType.race:
        return 'Đua';
    }
  }

  IconData get icon {
    switch (this) {
      case WorkoutType.rest:
        return Icons.hotel_rounded;
      case WorkoutType.walk:
        return Icons.directions_walk_rounded;
      case WorkoutType.easyRun:
        return Icons.directions_run_rounded;
      case WorkoutType.intervals:
        return Icons.speed_rounded;
      case WorkoutType.tempo:
        return Icons.trending_up_rounded;
      case WorkoutType.longRun:
        return Icons.route_rounded;
      case WorkoutType.race:
        return Icons.emoji_events_rounded;
    }
  }

  Color get color {
    switch (this) {
      case WorkoutType.rest:
        return Colors.grey;
      case WorkoutType.walk:
        return AuroraColors.mintLight;
      case WorkoutType.easyRun:
        return AuroraColors.mintSecondary;
      case WorkoutType.intervals:
        return AuroraColors.coralPrimary;
      case WorkoutType.tempo:
        return AuroraColors.warning;
      case WorkoutType.longRun:
        return AuroraColors.lavenderTertiary;
      case WorkoutType.race:
        return AuroraColors.coralDark;
    }
  }
}

@immutable
class PlanWorkout {
  const PlanWorkout({
    required this.dayOfWeek,
    required this.type,
    this.targetDistanceKm,
    this.targetDurationMin,
    required this.description,
    required this.coachNote,
  });

  /// 1 = Monday … 7 = Sunday.
  final int dayOfWeek;
  final WorkoutType type;
  final double? targetDistanceKm;
  final int? targetDurationMin;
  final String description;
  final String coachNote;

  bool get isRest => type == WorkoutType.rest;
}
