import 'package:runvie/data/models/badge.dart';
import 'package:runvie/services/run_events.dart';

/// Aggregated lifetime stats fed into the criteria evaluator. Backend is the
/// source of truth for awarding — this client-side evaluator is used to:
///
/// 1. preview progress bars in the badge gallery, and
/// 2. avoid showing the celebration modal until the server confirms.
class UserActivityStats {
  const UserActivityStats({
    required this.lifetimeKm,
    required this.currentStreakDays,
    required this.brokenStreakDaysLast,
    required this.runsByHour,
  });

  final double lifetimeKm;
  final int currentStreakDays;

  /// Most recent broken-streak length (drives Comeback King).
  final int brokenStreakDaysLast;

  /// Per-hour run counts (0..23) for time-of-day badges.
  final List<int> runsByHour;

  int totalRunsBetween(int hourStart, int hourEnd) {
    int sum = 0;
    final int start = hourStart.clamp(0, 23);
    final int end = hourEnd.clamp(1, 24);
    if (start < end) {
      for (int h = start; h < end; h++) {
        sum += runsByHour[h];
      }
    } else {
      // wrap-around (e.g. 22..2)
      for (int h = start; h < 24; h++) {
        sum += runsByHour[h];
      }
      for (int h = 0; h < end; h++) {
        sum += runsByHour[h];
      }
    }
    return sum;
  }
}

/// Evaluator returns a value in [0..1] representing progress towards the
/// criterion. 1.0 means the criterion is satisfied.
class BadgeCriteriaEvaluator {
  const BadgeCriteriaEvaluator();

  double progressFor(
    BadgeModel badge, {
    required UserActivityStats stats,
    RunSavedEvent? latestRun,
  }) {
    switch (badge.criteriaType) {
      case BadgeCriteriaType.distanceTotalKm:
        if (badge.criteriaValue <= 0) return 0;
        return _ratio(stats.lifetimeKm, badge.criteriaValue);
      case BadgeCriteriaType.distanceSingleKm:
        if (latestRun == null) return 0;
        return _ratio(latestRun.distanceKm, badge.criteriaValue);
      case BadgeCriteriaType.streakDays:
        return _ratio(
            stats.currentStreakDays.toDouble(), badge.criteriaValue);
      case BadgeCriteriaType.timeOfDay:
        final int hs = badge.criteriaHourStart ?? 0;
        final int he = badge.criteriaHourEnd ?? 24;
        final int got = stats.totalRunsBetween(hs, he);
        return _ratio(got.toDouble(), badge.criteriaValue);
      case BadgeCriteriaType.paceSub5K:
        if (latestRun == null || latestRun.distanceKm < 5) return 0;
        return latestRun.avgPaceSecPerKm > 0 &&
                latestRun.avgPaceSecPerKm <= badge.criteriaValue
            ? 1
            : 0;
      case BadgeCriteriaType.negativeSplit:
        // Cannot determine from single event payload — server only.
        return 0;
      case BadgeCriteriaType.exactDistance:
        if (latestRun == null) return 0;
        // Within 50m of the exact target.
        final double diff =
            (latestRun.distanceKm - badge.criteriaValue).abs();
        return diff <= 0.05 ? 1 : 0;
      case BadgeCriteriaType.comebackKing:
        // Awarded when a previously-broken streak (within window) is back
        // to >= criteriaValue days (default 1).
        if (stats.brokenStreakDaysLast <= 0) return 0;
        return stats.currentStreakDays >= badge.criteriaValue ? 1 : 0;
      case BadgeCriteriaType.custom:
        return 0;
    }
  }

  bool isSatisfied(
    BadgeModel badge, {
    required UserActivityStats stats,
    RunSavedEvent? latestRun,
  }) {
    return progressFor(badge, stats: stats, latestRun: latestRun) >= 1.0;
  }

  static double _ratio(double got, double target) {
    if (target <= 0) return 0;
    final double r = got / target;
    if (r.isNaN || r.isInfinite || r < 0) return 0;
    if (r > 1) return 1;
    return r;
  }
}
