import 'package:flutter/foundation.dart';

import 'package:runvie/data/models/daily_step.dart';

enum WorkoutKind {
  walk,
  easyRun,
  tempoRun,
  rest,
}

@immutable
class SuggestedWorkout {
  const SuggestedWorkout({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.targetDistanceKm,
    required this.targetDurationMinutes,
  });

  final WorkoutKind kind;
  final String title;
  final String subtitle;
  final double targetDistanceKm;
  final int targetDurationMinutes;
}

/// Pure decision function — no clocks, easy to unit-test.
///
/// Rules (in priority order):
/// 1. Streak >= 7 days hitting goal -> Tempo run.
/// 2. >= 2 consecutive rest days (no run, < 2000 steps) -> Easy run 3 km.
/// 3. After 18:00 and today's steps < 50% of goal -> light walk 20 min.
/// 4. Otherwise -> easy run 3 km.
class SuggestedWorkoutEngine {
  const SuggestedWorkoutEngine();

  SuggestedWorkout suggest({
    required int todaySteps,
    required int dailyGoal,
    required int currentStreak,
    required List<DailyStep> last7Days,
    required DateTime now,
    required bool ranToday,
  }) {
    if (currentStreak >= 7) {
      return const SuggestedWorkout(
        kind: WorkoutKind.tempoRun,
        title: 'Tempo run 5 km',
        subtitle: 'Streak đang nóng — giữ phong độ với tempo bền',
        targetDistanceKm: 5,
        targetDurationMinutes: 30,
      );
    }

    final int restDays = _trailingRestDays(last7Days);
    if (restDays >= 2 && !ranToday) {
      return const SuggestedWorkout(
        kind: WorkoutKind.easyRun,
        title: 'Easy run 3 km',
        subtitle: 'Quay lại nhẹ nhàng sau vài ngày nghỉ',
        targetDistanceKm: 3,
        targetDurationMinutes: 25,
      );
    }

    if (now.hour >= 18 && todaySteps < dailyGoal * 0.5) {
      return const SuggestedWorkout(
        kind: WorkoutKind.walk,
        title: 'Đi bộ 20 phút',
        subtitle: 'Bù bước cuối ngày để chạm mục tiêu',
        targetDistanceKm: 2,
        targetDurationMinutes: 20,
      );
    }

    return const SuggestedWorkout(
      kind: WorkoutKind.easyRun,
      title: 'Easy run 3 km',
      subtitle: 'Khởi động ngày năng động',
      targetDistanceKm: 3,
      targetDurationMinutes: 22,
    );
  }

  /// Trailing consecutive "rest" days at the END of [days]
  /// (most-recent first or last — we sort and walk backwards).
  /// "Rest" = under 2000 steps.
  static int _trailingRestDays(List<DailyStep> days) {
    if (days.isEmpty) return 0;
    final List<DailyStep> sorted = <DailyStep>[...days]
      ..sort((DailyStep a, DailyStep b) => a.date.compareTo(b.date));
    // Skip today itself (the "are we resting today" question is
    // handled separately by ranToday + step check).
    int count = 0;
    for (int i = sorted.length - 2; i >= 0; i--) {
      if (sorted[i].steps < 2000) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }
}
