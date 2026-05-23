import 'package:flutter/foundation.dart';

import 'package:runvie/features/plan/models/plan_week.dart';

enum PlanLevel { beginner, intermediate, advanced }

extension PlanLevelX on PlanLevel {
  String get label {
    switch (this) {
      case PlanLevel.beginner:
        return 'Người mới';
      case PlanLevel.intermediate:
        return 'Trung cấp';
      case PlanLevel.advanced:
        return 'Nâng cao';
    }
  }
}

@immutable
class PlanTemplate {
  const PlanTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.goalDistanceKm,
    required this.sessionsPerWeek,
    required this.weeks,
  });

  final String id;
  final String name;
  final String description;
  final PlanLevel level;
  final double goalDistanceKm;
  final int sessionsPerWeek;
  final List<PlanWeek> weeks;

  int get durationWeeks => weeks.length;
}
