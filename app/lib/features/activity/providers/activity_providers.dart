import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runvie/data/models/activity.dart';
import 'package:runvie/data/models/heatmap_data.dart';
import 'package:runvie/data/models/period_stats.dart';
import 'package:runvie/data/repositories/activity_repository.dart';

/// Shared [ActivityRepository] singleton. The production bootstrap will
/// override this with a Drift-backed implementation; the default keeps the
/// app runnable end-to-end without bindings.
final Provider<ActivityRepository> activityRepositoryProvider =
    Provider<ActivityRepository>((Ref ref) => InMemoryActivityRepository());

/// Listens for any change in the repo and forces dependent providers to
/// refresh.
final StreamProvider<void> activityChangesProvider =
    StreamProvider<void>((Ref ref) {
  return ref.watch(activityRepositoryProvider).watchChanges();
});

/// Recent activities (descending by [Activity.startedAt]).
final FutureProvider<List<Activity>> recentActivitiesProvider =
    FutureProvider<List<Activity>>((Ref ref) async {
  ref.watch(activityChangesProvider);
  return ref.watch(activityRepositoryProvider).getRecent(limit: 200);
});

/// 53 weeks × 7 days heatmap bucketed by local date.
final FutureProvider<Map<DateTime, HeatmapBucket>> heatmapDataProvider =
    FutureProvider<Map<DateTime, HeatmapBucket>>((Ref ref) async {
  ref.watch(activityChangesProvider);
  final DateTime now = DateTime.now();
  final DateTime start = HeatmapData.heatmapStart(now);
  final DateTime end = DateTime(now.year, now.month, now.day)
      .add(const Duration(days: 1));
  return ref
      .watch(activityRepositoryProvider)
      .getHeatmapData(from: start, to: end);
});

/// Stats for the currently-selected period.
final StateProvider<StatsPeriod> selectedStatsPeriodProvider =
    StateProvider<StatsPeriod>((Ref ref) => StatsPeriod.week);

final FutureProvider<PeriodStats> selectedPeriodStatsProvider =
    FutureProvider<PeriodStats>((Ref ref) async {
  ref.watch(activityChangesProvider);
  final StatsPeriod period = ref.watch(selectedStatsPeriodProvider);
  return ref.watch(activityRepositoryProvider).getStats(period);
});

/// Convenience: a single activity by id.
final FutureProviderFamily<Activity?, int> activityByIdProvider =
    FutureProvider.family<Activity?, int>((Ref ref, int id) async {
  ref.watch(activityChangesProvider);
  return ref.watch(activityRepositoryProvider).getById(id);
});
