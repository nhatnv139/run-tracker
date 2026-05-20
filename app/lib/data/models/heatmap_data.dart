import 'package:flutter/foundation.dart';

import 'package:runvie/data/models/activity.dart';

/// A single day's bucket on the GitHub-style heatmap.
@immutable
class HeatmapBucket {
  const HeatmapBucket({
    required this.date,
    required this.totalMeters,
    required this.activityCount,
  });

  /// Local-midnight DateTime for the day this bucket represents.
  final DateTime date;
  final double totalMeters;
  final int activityCount;

  double get totalKm => totalMeters / 1000.0;

  /// Discrete intensity bucket used to pick a cell color (0..4).
  ///
  /// Thresholds (km):
  ///   0          → 0  (neutral)
  ///   (0, 3]     → 1  (mint-100)
  ///   (3, 8]     → 2  (mint-300)
  ///   (8, 15]    → 3  (coral-400)
  ///   > 15       → 4  (coral-600)
  int get intensity {
    final double km = totalKm;
    if (km <= 0) return 0;
    if (km <= 3) return 1;
    if (km <= 8) return 2;
    if (km <= 15) return 3;
    return 4;
  }
}

/// Pure helpers for grouping activities into heatmap buckets.
class HeatmapData {
  HeatmapData._();

  /// Buckets [activities] by local date. Days without any activity are
  /// **not** included; the widget renders missing days as the neutral cell.
  static Map<DateTime, HeatmapBucket> groupByDate(List<Activity> activities) {
    final Map<DateTime, HeatmapBucket> map = <DateTime, HeatmapBucket>{};
    for (final Activity a in activities) {
      final DateTime key = a.localDate;
      final HeatmapBucket? existing = map[key];
      if (existing == null) {
        map[key] = HeatmapBucket(
          date: key,
          totalMeters: a.distanceMeters,
          activityCount: 1,
        );
      } else {
        map[key] = HeatmapBucket(
          date: key,
          totalMeters: existing.totalMeters + a.distanceMeters,
          activityCount: existing.activityCount + 1,
        );
      }
    }
    return map;
  }

  /// Returns the start-of-week (Monday) for the heatmap that ends on [end].
  /// We render 53 columns × 7 rows = 371 days.
  static DateTime heatmapStart(DateTime end) {
    final DateTime endDay = DateTime(end.year, end.month, end.day);
    // Align end to its week (Sunday as last column).
    final int daysFromMonday = endDay.weekday - DateTime.monday;
    final DateTime weekStart = endDay.subtract(Duration(days: daysFromMonday));
    return weekStart.subtract(const Duration(days: 7 * 52));
  }
}
