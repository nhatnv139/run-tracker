import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/features/plan/data/plan_templates.dart';
import 'package:runvie/features/plan/models/active_plan.dart';
import 'package:runvie/features/plan/models/plan_template.dart';
import 'package:runvie/features/plan/models/plan_week.dart';
import 'package:runvie/features/plan/models/plan_workout.dart';
import 'package:runvie/features/plan/providers/plan_providers.dart';

class FullPlanScreen extends ConsumerWidget {
  const FullPlanScreen({super.key});

  static const List<String> _weekdayShort = <String>[
    '', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ActivePlan? plan = ref.watch(activePlanProvider).valueOrNull;
    final PlanTemplate? template =
        plan == null ? null : PlanTemplates.byId(plan.templateId);
    if (plan == null || template == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Toàn bộ giáo án')),
        body: const Center(child: Text('Chưa có giáo án đang chạy.')),
      );
    }
    final int currentWeek = plan.currentWeek().clamp(1, template.durationWeeks);

    return Scaffold(
      appBar: AppBar(title: Text(template.name)),
      body: ListView.builder(
        padding: const EdgeInsets.all(AuroraSpacing.lg),
        itemCount: template.weeks.length,
        itemBuilder: (BuildContext context, int i) {
          final PlanWeek week = template.weeks[i];
          final bool isCurrent = week.number == currentWeek;
          final bool isPast = week.number < currentWeek;
          return ExpansionTile(
            initiallyExpanded: isCurrent,
            title: Row(
              children: <Widget>[
                Text('Tuần ${week.number}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isCurrent ? AuroraColors.coralPrimary : null,
                        )),
                const SizedBox(width: AuroraSpacing.sm),
                if (isCurrent)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AuroraColors.coralPrimary,
                      borderRadius:
                          BorderRadius.circular(AuroraSpacing.radiusPill),
                    ),
                    child: const Text('hiện tại',
                        style: TextStyle(color: Colors.white, fontSize: 11)),
                  )
                else if (isPast)
                  const Icon(Icons.check_rounded,
                      size: 16, color: AuroraColors.success),
              ],
            ),
            children: <Widget>[
              for (int d = 1; d <= 7; d++)
                _WorkoutRow(
                  weekday: d,
                  weekdayLabel: _weekdayShort[d],
                  workout: week.workoutOnDay(d),
                  done: plan.completedWorkouts
                      .contains(ActivePlan.workoutKey(week.number, d)),
                  locked: week.number > currentWeek,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _WorkoutRow extends StatelessWidget {
  const _WorkoutRow({
    required this.weekday,
    required this.weekdayLabel,
    required this.workout,
    required this.done,
    required this.locked,
  });
  final int weekday;
  final String weekdayLabel;
  final PlanWorkout? workout;
  final bool done;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final WorkoutType type = workout?.type ?? WorkoutType.rest;
    final Color subdued = Theme.of(context).colorScheme.outline;
    return ListTile(
      leading: SizedBox(
        width: 36,
        child: Text(weekdayLabel,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge),
      ),
      title: Text(
        workout?.description ?? 'Nghỉ',
        style: locked ? TextStyle(color: subdued) : null,
      ),
      subtitle: workout != null && !workout!.isRest
          ? Text(
              <String>[
                if (workout!.targetDistanceKm != null)
                  '${workout!.targetDistanceKm!.toStringAsFixed(workout!.targetDistanceKm!.truncateToDouble() == workout!.targetDistanceKm ? 0 : 1)} km',
                if (workout!.targetDurationMin != null)
                  '${workout!.targetDurationMin} phút',
              ].join(' · '),
              style: TextStyle(color: subdued),
            )
          : null,
      trailing: locked
          ? const Icon(Icons.lock_outline_rounded, size: 18, color: Colors.grey)
          : done
              ? const Icon(Icons.check_circle_rounded,
                  color: AuroraColors.success)
              : Icon(type.icon, color: type.color),
    );
  }
}
