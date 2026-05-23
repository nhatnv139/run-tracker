import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runvie/core/router/routes.dart';
import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/features/plan/models/active_plan.dart';
import 'package:runvie/features/plan/models/plan_template.dart';
import 'package:runvie/features/plan/models/plan_week.dart';
import 'package:runvie/features/plan/models/plan_workout.dart';
import 'package:runvie/features/plan/data/plan_templates.dart';
import 'package:runvie/features/plan/providers/plan_providers.dart';
import 'package:runvie/shared/widgets/aurora_button.dart';
import 'package:runvie/shared/widgets/aurora_card.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ActivePlan?> planAsync = ref.watch(activePlanProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Giáo án')),
      body: planAsync.when(
        data: (ActivePlan? plan) {
          if (plan == null) return const _TemplatePicker();
          final PlanTemplate? template = PlanTemplates.byId(plan.templateId);
          if (template == null) return const _TemplatePicker();
          return _ActivePlanView(plan: plan, template: template);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }
}

class _TemplatePicker extends ConsumerWidget {
  const _TemplatePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<PlanTemplate> templates = ref.watch(planTemplatesProvider);
    return ListView(
      padding: const EdgeInsets.all(AuroraSpacing.lg),
      children: <Widget>[
        Text('Chọn giáo án phù hợp',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                )),
        const SizedBox(height: AuroraSpacing.xs),
        Text(
          'Một giáo án cấu trúc giúp bạn tiến bộ đều và tránh chấn thương.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AuroraSpacing.lg),
        for (final PlanTemplate t in templates)
          Padding(
            padding: const EdgeInsets.only(bottom: AuroraSpacing.md),
            child: AuroraCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(Icons.flag_rounded,
                          color: AuroraColors.coralPrimary),
                      const SizedBox(width: AuroraSpacing.sm),
                      Expanded(
                        child: Text(t.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                      Chip(
                        label: Text(t.level.label),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: AuroraSpacing.xs),
                  Text(t.description),
                  const SizedBox(height: AuroraSpacing.sm),
                  Row(
                    children: <Widget>[
                      _Pill(icon: Icons.calendar_today_rounded, text: '${t.durationWeeks} tuần'),
                      const SizedBox(width: AuroraSpacing.xs),
                      _Pill(icon: Icons.repeat_rounded, text: '${t.sessionsPerWeek} buổi/tuần'),
                      const SizedBox(width: AuroraSpacing.xs),
                      _Pill(icon: Icons.straighten_rounded, text: '${t.goalDistanceKm.toStringAsFixed(0)} km'),
                    ],
                  ),
                  const SizedBox(height: AuroraSpacing.md),
                  AuroraButton(
                    label: 'Bắt đầu giáo án',
                    variant: AuroraButtonVariant.gradient,
                    onPressed: () async {
                      await ref
                          .read(activePlanProvider.notifier)
                          .startPlan(t.id);
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ActivePlanView extends ConsumerWidget {
  const _ActivePlanView({required this.plan, required this.template});
  final ActivePlan plan;
  final PlanTemplate template;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int currentWeek =
        plan.currentWeek().clamp(1, template.durationWeeks);
    final PlanWeek week = template.weeks[currentWeek - 1];
    final PlanWorkout? today = week.workoutOnDay(DateTime.now().weekday);
    final String todayKey = today == null
        ? ''
        : ActivePlan.workoutKey(currentWeek, today.dayOfWeek);
    final bool todayDone = plan.completedWorkouts.contains(todayKey);
    final double progress = currentWeek / template.durationWeeks;

    return ListView(
      padding: const EdgeInsets.all(AuroraSpacing.lg),
      children: <Widget>[
        AuroraCard(
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      color: AuroraColors.coralPrimary,
                      backgroundColor: AuroraColors.coralPrimary.withValues(alpha: 0.15),
                    ),
                    Text('$currentWeek/${template.durationWeeks}',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(width: AuroraSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(template.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            )),
                    Text('Tuần $currentWeek — ${week.workouts.where((PlanWorkout w) => !w.isRest).length} buổi tập',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AuroraSpacing.md),
        if (today != null) _TodayCard(
          workout: today,
          done: todayDone,
          onStart: () => context.push(AppRoutes.run),
          onToggleDone: () async {
            final notifier = ref.read(activePlanProvider.notifier);
            if (todayDone) {
              await notifier.unmarkDone(currentWeek, today.dayOfWeek);
            } else {
              await notifier.markDone(currentWeek, today.dayOfWeek);
            }
          },
        ),
        const SizedBox(height: AuroraSpacing.md),
        _WeekOverview(
          week: week,
          weekNumber: currentWeek,
          completed: plan.completedWorkouts,
        ),
        const SizedBox(height: AuroraSpacing.lg),
        AuroraButton(
          label: 'Xem toàn bộ giáo án',
          variant: AuroraButtonVariant.secondary,
          icon: Icons.list_alt_rounded,
          onPressed: () => context.push(AppRoutes.planFull),
        ),
        const SizedBox(height: AuroraSpacing.sm),
        TextButton(
          onPressed: () async {
            final bool? ok = await showDialog<bool>(
              context: context,
              builder: (BuildContext c) => AlertDialog(
                title: const Text('Hủy giáo án?'),
                content: const Text('Bạn sẽ mất tiến độ hiện tại. Có chắc không?'),
                actions: <Widget>[
                  TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Hủy bỏ')),
                  FilledButton(
                    onPressed: () => Navigator.pop(c, true),
                    style: FilledButton.styleFrom(backgroundColor: AuroraColors.error),
                    child: const Text('Vẫn hủy'),
                  ),
                ],
              ),
            );
            if (ok == true) {
              await ref.read(activePlanProvider.notifier).cancel();
            }
          },
          child: const Text('Hủy giáo án',
              style: TextStyle(color: AuroraColors.error)),
        ),
        const SizedBox(height: AuroraSpacing.xxxl),
      ],
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.workout,
    required this.done,
    required this.onStart,
    required this.onToggleDone,
  });
  final PlanWorkout workout;
  final bool done;
  final VoidCallback onStart;
  final VoidCallback onToggleDone;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return AuroraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(AuroraSpacing.sm),
                decoration: BoxDecoration(
                  color: workout.type.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AuroraSpacing.radiusMd),
                ),
                child: Icon(workout.type.icon, color: workout.type.color),
              ),
              const SizedBox(width: AuroraSpacing.sm),
              Text('Buổi hôm nay · ${workout.type.label}',
                  style: text.labelLarge?.copyWith(
                        color: workout.type.color,
                        fontWeight: FontWeight.w700,
                      )),
              const Spacer(),
              if (done)
                const Chip(
                  label: Text('Đã hoàn thành'),
                  backgroundColor: Color(0xFFE4F8EE),
                  labelStyle: TextStyle(color: AuroraColors.success),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: AuroraSpacing.sm),
          Text(workout.description, style: text.titleMedium),
          if (workout.targetDistanceKm != null ||
              workout.targetDurationMin != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              <String>[
                if (workout.targetDistanceKm != null)
                  '${workout.targetDistanceKm!.toStringAsFixed(workout.targetDistanceKm!.truncateToDouble() == workout.targetDistanceKm ? 0 : 1)} km',
                if (workout.targetDurationMin != null)
                  '${workout.targetDurationMin} phút',
              ].join(' · '),
              style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: AuroraSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AuroraSpacing.sm),
            decoration: BoxDecoration(
              color: AuroraColors.mintSecondary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AuroraSpacing.radiusMd),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.lightbulb_outline_rounded,
                    size: 16, color: AuroraColors.mintSecondary),
                const SizedBox(width: AuroraSpacing.xs),
                Expanded(
                  child: Text(workout.coachNote,
                      style: text.bodySmall),
                ),
              ],
            ),
          ),
          const SizedBox(height: AuroraSpacing.md),
          if (!workout.isRest)
            Row(
              children: <Widget>[
                Expanded(
                  child: AuroraButton(
                    label: done ? 'Bỏ đánh dấu' : 'Bắt đầu chạy',
                    icon: done ? Icons.refresh_rounded : Icons.play_arrow_rounded,
                    variant: done
                        ? AuroraButtonVariant.secondary
                        : AuroraButtonVariant.gradient,
                    onPressed: done ? onToggleDone : onStart,
                  ),
                ),
                if (!done) ...<Widget>[
                  const SizedBox(width: AuroraSpacing.sm),
                  IconButton.outlined(
                    onPressed: onToggleDone,
                    icon: const Icon(Icons.check_rounded),
                    tooltip: 'Đã hoàn thành',
                  ),
                ],
              ],
            )
          else
            AuroraButton(
              label: 'Hôm nay là ngày nghỉ',
              variant: AuroraButtonVariant.secondary,
              onPressed: () {},
            ),
        ],
      ),
    );
  }
}

class _WeekOverview extends StatelessWidget {
  const _WeekOverview({
    required this.week,
    required this.weekNumber,
    required this.completed,
  });
  final PlanWeek week;
  final int weekNumber;
  final Set<String> completed;

  static const List<String> _weekdayShort = <String>[
    '', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN',
  ];

  @override
  Widget build(BuildContext context) {
    final int today = DateTime.now().weekday;
    return AuroraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Tuần $weekNumber',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AuroraSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              for (int d = 1; d <= 7; d++) _DayChip(
                label: _weekdayShort[d],
                workout: week.workoutOnDay(d),
                isToday: d == today,
                done: completed
                    .contains(ActivePlan.workoutKey(weekNumber, d)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.workout,
    required this.isToday,
    required this.done,
  });
  final String label;
  final PlanWorkout? workout;
  final bool isToday;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final WorkoutType type = workout?.type ?? WorkoutType.rest;
    final Color color = type.color;
    return Column(
      children: <Widget>[
        Text(label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: isToday ? FontWeight.w700 : null,
                  color: isToday ? AuroraColors.coralPrimary : null,
                )),
        const SizedBox(height: 4),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? color : color.withValues(alpha: 0.15),
            border: isToday
                ? Border.all(color: AuroraColors.coralPrimary, width: 1.5)
                : null,
          ),
          child: Icon(
            done ? Icons.check_rounded : type.icon,
            size: 18,
            color: done ? Colors.white : color,
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AuroraSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AuroraSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12),
          const SizedBox(width: 4),
          Text(text, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
