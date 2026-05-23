import 'package:flutter/foundation.dart';

@immutable
class ActivePlan {
  const ActivePlan({
    required this.templateId,
    required this.startDate,
    this.completedWorkouts = const <String>{},
  });

  final String templateId;
  final DateTime startDate;

  /// Keys of completed workouts in form "w{week}-d{dayOfWeek}".
  final Set<String> completedWorkouts;

  /// 1-indexed current week based on startDate.
  int currentWeek({DateTime? now}) {
    final DateTime n = now ?? DateTime.now();
    final int days = n.difference(startDate).inDays;
    return (days ~/ 7) + 1;
  }

  static String workoutKey(int week, int day) => 'w$week-d$day';

  ActivePlan copyWith({
    String? templateId,
    DateTime? startDate,
    Set<String>? completedWorkouts,
  }) {
    return ActivePlan(
      templateId: templateId ?? this.templateId,
      startDate: startDate ?? this.startDate,
      completedWorkouts: completedWorkouts ?? this.completedWorkouts,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'templateId': templateId,
        'startDate': startDate.toIso8601String(),
        'completedWorkouts': completedWorkouts.toList(),
      };

  factory ActivePlan.fromJson(Map<String, dynamic> j) => ActivePlan(
        templateId: j['templateId'] as String,
        startDate: DateTime.parse(j['startDate'] as String),
        completedWorkouts: ((j['completedWorkouts'] as List<dynamic>?) ?? <dynamic>[])
            .cast<String>()
            .toSet(),
      );
}
