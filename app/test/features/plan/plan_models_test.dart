import 'package:flutter_test/flutter_test.dart';

import 'package:runvie/features/plan/data/plan_templates.dart';
import 'package:runvie/features/plan/models/active_plan.dart';
import 'package:runvie/features/plan/models/plan_template.dart';
import 'package:runvie/features/plan/models/plan_workout.dart';

void main() {
  group('PlanTemplates', () {
    test('beginner5k is 8 weeks with 3 work sessions per week (avg)', () {
      final PlanTemplate t = PlanTemplates.beginner5k;
      expect(t.durationWeeks, 8);
      expect(t.weeks.length, 8);
      expect(t.goalDistanceKm, 5);
      expect(t.level, PlanLevel.beginner);
    });

    test('tenK is 6 weeks with race in final week', () {
      final PlanTemplate t = PlanTemplates.tenK;
      expect(t.durationWeeks, 6);
      final PlanWorkout? race = t.weeks.last.workoutOnDay(7);
      expect(race, isNotNull);
      expect(race!.type, WorkoutType.race);
      expect(race.targetDistanceKm, 10);
    });

    test('byId resolves both templates and returns null for unknown', () {
      expect(PlanTemplates.byId('beginner-5k-8w'), isNotNull);
      expect(PlanTemplates.byId('ten-k-6w'), isNotNull);
      expect(PlanTemplates.byId('does-not-exist'), isNull);
    });

    test('every workout has a Vietnamese coach note', () {
      for (final PlanTemplate t in PlanTemplates.all) {
        for (final week in t.weeks) {
          for (final PlanWorkout w in week.workouts) {
            expect(w.coachNote, isNotEmpty,
                reason: '${t.id} w${week.number} d${w.dayOfWeek} missing coach note');
          }
        }
      }
    });
  });

  group('ActivePlan', () {
    test('currentWeek 1 immediately after starting', () {
      final ActivePlan p = ActivePlan(
        templateId: 'beginner-5k-8w',
        startDate: DateTime.now(),
      );
      expect(p.currentWeek(), 1);
    });

    test('currentWeek 2 after 7 days', () {
      final DateTime start = DateTime(2026, 1, 1);
      final ActivePlan p = ActivePlan(templateId: 'x', startDate: start);
      expect(p.currentWeek(now: start.add(const Duration(days: 7))), 2);
    });

    test('workoutKey is week-day formatted', () {
      expect(ActivePlan.workoutKey(3, 5), 'w3-d5');
    });

    test('JSON round-trip preserves completed workouts', () {
      final ActivePlan original = ActivePlan(
        templateId: 'ten-k-6w',
        startDate: DateTime(2026, 5, 1),
        completedWorkouts: <String>{'w1-d1', 'w1-d3'},
      );
      final ActivePlan back = ActivePlan.fromJson(original.toJson());
      expect(back.templateId, original.templateId);
      expect(back.startDate, original.startDate);
      expect(back.completedWorkouts, original.completedWorkouts);
    });
  });
}
