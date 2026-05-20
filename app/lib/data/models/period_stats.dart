import 'package:flutter/foundation.dart';

import 'package:runvie/data/models/activity.dart';

/// Aggregation period used by the stats summary tiles.
enum StatsPeriod {
  week,
  month,
  year,
  allTime,
  ;

  String get label {
    switch (this) {
      case StatsPeriod.week:
        return 'Tuần này';
      case StatsPeriod.month:
        return 'Tháng này';
      case StatsPeriod.year:
        return 'Năm nay';
      case StatsPeriod.allTime:
        return 'Toàn thời gian';
    }
  }
}

/// Summary numbers for a period.
@immutable
class PeriodStats {
  const PeriodStats({
    required this.period,
    required this.totalMeters,
    required this.totalDuration,
    required this.totalRuns,
    required this.totalCalories,
    required this.longestRunMeters,
    required this.fastestPaceSecPerKm,
  });

  factory PeriodStats.empty(StatsPeriod period) => PeriodStats(
        period: period,
        totalMeters: 0,
        totalDuration: Duration.zero,
        totalRuns: 0,
        totalCalories: 0,
        longestRunMeters: 0,
        fastestPaceSecPerKm: 0,
      );

  final StatsPeriod period;
  final double totalMeters;
  final Duration totalDuration;
  final int totalRuns;
  final double totalCalories;
  final double longestRunMeters;
  final double fastestPaceSecPerKm;

  double get totalKm => totalMeters / 1000.0;
}

/// Pure aggregation helpers.
class StatsCalc {
  StatsCalc._();

  /// Returns `true` if [when] falls within the period anchored at [now].
  static bool inPeriod(DateTime when, StatsPeriod period, DateTime now) {
    switch (period) {
      case StatsPeriod.week:
        final DateTime weekStart = _startOfWeek(now);
        final DateTime weekEnd = weekStart.add(const Duration(days: 7));
        return !when.isBefore(weekStart) && when.isBefore(weekEnd);
      case StatsPeriod.month:
        return when.year == now.year && when.month == now.month;
      case StatsPeriod.year:
        return when.year == now.year;
      case StatsPeriod.allTime:
        return true;
    }
  }

  /// Aggregates the activities matching [period] using [now] as anchor.
  static PeriodStats aggregate(
    List<Activity> activities,
    StatsPeriod period, {
    DateTime? now,
  }) {
    final DateTime anchor = now ?? DateTime.now();
    final List<Activity> filtered = activities
        .where((Activity a) => inPeriod(a.startedAt, period, anchor))
        .toList();
    if (filtered.isEmpty) return PeriodStats.empty(period);

    double meters = 0;
    int durationSec = 0;
    double calories = 0;
    double longest = 0;
    double fastest = double.infinity;

    for (final Activity a in filtered) {
      meters += a.distanceMeters;
      durationSec += a.duration.inSeconds;
      calories += a.calories;
      if (a.distanceMeters > longest) longest = a.distanceMeters;
      if (a.avgPaceSecPerKm > 0 && a.avgPaceSecPerKm < fastest) {
        fastest = a.avgPaceSecPerKm;
      }
    }

    return PeriodStats(
      period: period,
      totalMeters: meters,
      totalDuration: Duration(seconds: durationSec),
      totalRuns: filtered.length,
      totalCalories: calories,
      longestRunMeters: longest,
      fastestPaceSecPerKm: fastest.isFinite ? fastest : 0,
    );
  }

  /// 12-week trend: each entry contains the Monday of the week and the
  /// distance, total elevation, and avg pace within that week.
  static List<WeeklyTrendPoint> weeklyTrend(
    List<Activity> activities, {
    DateTime? now,
    int weeks = 12,
  }) {
    final DateTime anchor = now ?? DateTime.now();
    final DateTime currentWeekStart = _startOfWeek(anchor);
    final List<WeeklyTrendPoint> result = <WeeklyTrendPoint>[];

    for (int w = weeks - 1; w >= 0; w--) {
      final DateTime weekStart =
          currentWeekStart.subtract(Duration(days: 7 * w));
      final DateTime weekEnd = weekStart.add(const Duration(days: 7));
      final List<Activity> inWeek = activities
          .where((Activity a) =>
              !a.startedAt.isBefore(weekStart) &&
              a.startedAt.isBefore(weekEnd))
          .toList();

      double meters = 0;
      double elev = 0;
      double totalPaceWeighted = 0;
      double totalKm = 0;
      for (final Activity a in inWeek) {
        meters += a.distanceMeters;
        elev += a.elevationGainM;
        final double km = a.distanceMeters / 1000.0;
        if (km > 0 && a.avgPaceSecPerKm > 0) {
          totalPaceWeighted += a.avgPaceSecPerKm * km;
          totalKm += km;
        }
      }
      final double avgPace = totalKm > 0 ? totalPaceWeighted / totalKm : 0;

      result.add(WeeklyTrendPoint(
        weekStart: weekStart,
        totalMeters: meters,
        elevationGainM: elev,
        avgPaceSecPerKm: avgPace,
      ));
    }
    return result;
  }

  /// Sums HR zone seconds across activities within the period.
  static List<int> hrZoneTotals(
    List<Activity> activities,
    StatsPeriod period, {
    DateTime? now,
  }) {
    final DateTime anchor = now ?? DateTime.now();
    final List<int> totals = <int>[0, 0, 0, 0, 0];
    for (final Activity a in activities) {
      if (!inPeriod(a.startedAt, period, anchor)) continue;
      for (int i = 0; i < 5 && i < a.hrZoneSeconds.length; i++) {
        totals[i] += a.hrZoneSeconds[i];
      }
    }
    return totals;
  }

  static DateTime _startOfWeek(DateTime when) {
    final DateTime day = DateTime(when.year, when.month, when.day);
    final int dayFromMonday = day.weekday - DateTime.monday;
    return day.subtract(Duration(days: dayFromMonday));
  }
}

@immutable
class WeeklyTrendPoint {
  const WeeklyTrendPoint({
    required this.weekStart,
    required this.totalMeters,
    required this.elevationGainM,
    required this.avgPaceSecPerKm,
  });

  final DateTime weekStart;
  final double totalMeters;
  final double elevationGainM;
  final double avgPaceSecPerKm;

  double get totalKm => totalMeters / 1000.0;
}
