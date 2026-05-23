import 'package:flutter/foundation.dart';

import 'package:runvie/features/plan/models/plan_workout.dart';

@immutable
class PlanWeek {
  const PlanWeek({required this.number, required this.workouts});
  final int number;
  final List<PlanWorkout> workouts;

  PlanWorkout? workoutOnDay(int dayOfWeek) {
    for (final PlanWorkout w in workouts) {
      if (w.dayOfWeek == dayOfWeek) return w;
    }
    return null;
  }
}
