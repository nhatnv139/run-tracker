import 'dart:async';

import 'package:runvie/data/models/activity.dart';
import 'package:runvie/data/models/heatmap_data.dart';
import 'package:runvie/data/models/period_stats.dart';
import 'package:runvie/data/models/personal_record.dart';
import 'package:runvie/data/models/pr_detector.dart';

/// Abstract activity data source. The production binding wraps Drift +
/// Supabase; tests provide [InMemoryActivityRepository].
abstract class ActivityRepository {
  Future<List<Activity>> getRecent({int limit = 20, int offset = 0});

  Future<List<Activity>> getByDateRange(DateTime from, DateTime to);

  Future<Activity?> getById(int id);

  Future<Activity> save(Activity activity);

  Future<void> delete(int id);

  /// Re-attempts cloud sync of a previously-failed activity.
  Future<Activity> retrySync(int id);

  /// Returns all currently-recorded PRs.
  Future<Map<PrKind, PersonalRecord>> getPRs();

  /// Returns a Map keyed by local date for the given range.
  Future<Map<DateTime, HeatmapBucket>> getHeatmapData({
    required DateTime from,
    required DateTime to,
  });

  /// Aggregated stats for the requested [period].
  Future<PeriodStats> getStats(StatsPeriod period, {DateTime? now});

  /// 12-week trend points used by the trend chart.
  Future<List<WeeklyTrendPoint>> getWeeklyStats({int weeks = 12});

  Future<List<int>> getHrZoneTotals(StatsPeriod period, {DateTime? now});

  /// Stream that fires whenever data changes (used by Riverpod refresh).
  Stream<void> watchChanges();
}

/// Lightweight in-memory implementation used by tests and as a fallback
/// before the Drift bindings are generated. Persists nothing.
class InMemoryActivityRepository implements ActivityRepository {
  InMemoryActivityRepository();

  final Map<int, Activity> _store = <int, Activity>{};
  final Map<PrKind, PersonalRecord> _prs = <PrKind, PersonalRecord>{};
  final StreamController<void> _changes =
      StreamController<void>.broadcast();
  int _nextId = 1;

  void seed(List<Activity> initial) {
    for (final Activity a in initial) {
      final int id = a.id == 0 ? _nextId++ : a.id;
      _store[id] = a.copyWith(id: id);
      if (id >= _nextId) _nextId = id + 1;
    }
    _recomputePrs();
  }

  List<Activity> get _sortedDesc {
    final List<Activity> all = _store.values.toList()
      ..sort((Activity a, Activity b) => b.startedAt.compareTo(a.startedAt));
    return all;
  }

  @override
  Future<List<Activity>> getRecent({int limit = 20, int offset = 0}) async {
    final List<Activity> sorted = _sortedDesc;
    if (offset >= sorted.length) return <Activity>[];
    final int end =
        (offset + limit) > sorted.length ? sorted.length : offset + limit;
    return sorted.sublist(offset, end);
  }

  @override
  Future<List<Activity>> getByDateRange(DateTime from, DateTime to) async {
    return _store.values
        .where((Activity a) =>
            !a.startedAt.isBefore(from) && a.startedAt.isBefore(to))
        .toList()
      ..sort((Activity a, Activity b) => b.startedAt.compareTo(a.startedAt));
  }

  @override
  Future<Activity?> getById(int id) async => _store[id];

  @override
  Future<Activity> save(Activity activity) async {
    final int id = activity.id == 0 ? _nextId++ : activity.id;
    final Activity stored = activity.copyWith(id: id);
    _store[id] = stored;
    _recomputePrs();
    _changes.add(null);
    return stored;
  }

  @override
  Future<void> delete(int id) async {
    _store.remove(id);
    _recomputePrs();
    _changes.add(null);
  }

  @override
  Future<Activity> retrySync(int id) async {
    final Activity? current = _store[id];
    if (current == null) {
      throw StateError('Activity $id not found');
    }
    final Activity updated =
        current.copyWith(syncStatus: ActivitySyncStatus.synced);
    _store[id] = updated;
    _changes.add(null);
    return updated;
  }

  @override
  Future<Map<PrKind, PersonalRecord>> getPRs() async =>
      Map<PrKind, PersonalRecord>.from(_prs);

  @override
  Future<Map<DateTime, HeatmapBucket>> getHeatmapData({
    required DateTime from,
    required DateTime to,
  }) async {
    final List<Activity> filtered = await getByDateRange(from, to);
    return HeatmapData.groupByDate(filtered);
  }

  @override
  Future<PeriodStats> getStats(StatsPeriod period, {DateTime? now}) async {
    return StatsCalc.aggregate(_store.values.toList(), period, now: now);
  }

  @override
  Future<List<WeeklyTrendPoint>> getWeeklyStats({int weeks = 12}) async {
    return StatsCalc.weeklyTrend(_store.values.toList(), weeks: weeks);
  }

  @override
  Future<List<int>> getHrZoneTotals(StatsPeriod period,
      {DateTime? now}) async {
    return StatsCalc.hrZoneTotals(_store.values.toList(), period, now: now);
  }

  @override
  Stream<void> watchChanges() => _changes.stream;

  void _recomputePrs() {
    _prs
      ..clear()
      ..addAll(PrDetector.computeAll(_store.values.toList()));
  }
}
