import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runvie/features/plan/data/plan_repository.dart';
import 'package:runvie/features/plan/data/plan_templates.dart';
import 'package:runvie/features/plan/models/active_plan.dart';
import 'package:runvie/features/plan/models/plan_template.dart';
import 'package:runvie/features/plan/models/plan_week.dart';
import 'package:runvie/features/plan/models/plan_workout.dart';

final Provider<PlanRepository> planRepositoryProvider =
    Provider<PlanRepository>((Ref ref) {
  final PlanRepository repo = PlanRepository();
  ref.onDispose(repo.dispose);
  return repo;
});

final Provider<List<PlanTemplate>> planTemplatesProvider =
    Provider<List<PlanTemplate>>((Ref ref) => PlanTemplates.all);

class ActivePlanNotifier extends AsyncNotifier<ActivePlan?> {
  @override
  Future<ActivePlan?> build() async {
    return ref.read(planRepositoryProvider).load();
  }

  Future<void> startPlan(String templateId) async {
    final ActivePlan plan =
        await ref.read(planRepositoryProvider).startPlan(templateId);
    state = AsyncData<ActivePlan?>(plan);
  }

  Future<void> markDone(int week, int day) async {
    final ActivePlan plan =
        await ref.read(planRepositoryProvider).markDone(week, day);
    state = AsyncData<ActivePlan?>(plan);
  }

  Future<void> unmarkDone(int week, int day) async {
    final ActivePlan plan =
        await ref.read(planRepositoryProvider).unmarkDone(week, day);
    state = AsyncData<ActivePlan?>(plan);
  }

  Future<void> cancel() async {
    await ref.read(planRepositoryProvider).cancel();
    state = const AsyncData<ActivePlan?>(null);
  }
}

final AsyncNotifierProvider<ActivePlanNotifier, ActivePlan?>
    activePlanProvider =
    AsyncNotifierProvider<ActivePlanNotifier, ActivePlan?>(
        ActivePlanNotifier.new);

/// Today's workout = active plan + today's weekday.
final Provider<PlanWorkout?> todayWorkoutProvider =
    Provider<PlanWorkout?>((Ref ref) {
  final ActivePlan? plan = ref.watch(activePlanProvider).valueOrNull;
  if (plan == null) return null;
  final PlanTemplate? template = PlanTemplates.byId(plan.templateId);
  if (template == null) return null;
  final int week = plan.currentWeek().clamp(1, template.durationWeeks);
  final PlanWeek planWeek = template.weeks[week - 1];
  return planWeek.workoutOnDay(DateTime.now().weekday);
});

final Provider<({int week, int total})?> planWeekInfoProvider =
    Provider<({int week, int total})?>((Ref ref) {
  final ActivePlan? plan = ref.watch(activePlanProvider).valueOrNull;
  if (plan == null) return null;
  final PlanTemplate? template = PlanTemplates.byId(plan.templateId);
  if (template == null) return null;
  final int week = plan.currentWeek().clamp(1, template.durationWeeks);
  return (week: week, total: template.durationWeeks);
});
