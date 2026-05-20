import 'dart:async';

import 'package:drift/drift.dart';

import 'package:runvie/data/local/app_database.dart';
import 'package:runvie/data/models/daily_step.dart';

/// Source of truth for daily step aggregates.
///
/// - Writes go to Drift `daily_steps` table keyed on (date, source).
/// - Reads dedupe across sources by picking the maximum step count per
///   day (the assumption: phones double-count, but never report fewer
///   steps than were actually taken).
/// - Exposes a [StepsDataSource] interface so tests can swap in a fake
///   without booting Drift.
abstract class StepsDataSource {
  Future<void> upsert(DailyStep step);
  Future<List<DailyStep>> rangeByDate(DateTime start, DateTime end);
  Future<DailyStep?> forDate(DateTime date);
  Stream<List<DailyStep>> watchRange(DateTime start, DateTime end);
}

/// Drift-backed implementation. The generated `daily_steps` accessor is
/// produced by `dart run build_runner build`.
class DriftStepsDataSource implements StepsDataSource {
  DriftStepsDataSource(this._db);
  final AppDatabase _db;

  @override
  Future<void> upsert(DailyStep step) async {
    final DateTime day = _dateOnly(step.date);
    final DateTime now = step.updatedAt ?? DateTime.now();
    await _db.into(_db.dailyStepsTable).insertOnConflictUpdate(
          DailyStepsTableCompanion.insert(
            date: day,
            source: Value<String>(step.source.name),
            steps: Value<int>(step.steps),
            distanceMeters: Value<double>(step.distanceMeters),
            calories: Value<double>(step.calories),
            activeMinutes: Value<int>(step.activeMinutes),
            updatedAt: now,
          ),
        );
  }

  @override
  Future<List<DailyStep>> rangeByDate(DateTime start, DateTime end) async {
    final DateTime s = _dateOnly(start);
    final DateTime e = _dateOnly(end);
    final List<DailyStepRow> rows = await (_db.select(_db.dailyStepsTable)
          ..where(($DailyStepsTableTable t) =>
              t.date.isBetweenValues(s, e))
          ..orderBy(<OrderClauseGenerator<$DailyStepsTableTable>>[
            ($DailyStepsTableTable t) =>
                OrderingTerm(expression: t.date),
          ]))
        .get();
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<DailyStep?> forDate(DateTime date) async {
    final DateTime d = _dateOnly(date);
    final DailyStepRow? row = await (_db.select(_db.dailyStepsTable)
          ..where(($DailyStepsTableTable t) => t.date.equals(d))
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Stream<List<DailyStep>> watchRange(DateTime start, DateTime end) {
    final DateTime s = _dateOnly(start);
    final DateTime e = _dateOnly(end);
    return (_db.select(_db.dailyStepsTable)
          ..where(($DailyStepsTableTable t) =>
              t.date.isBetweenValues(s, e))
          ..orderBy(<OrderClauseGenerator<$DailyStepsTableTable>>[
            ($DailyStepsTableTable t) =>
                OrderingTerm(expression: t.date),
          ]))
        .watch()
        .map((List<DailyStepRow> rows) =>
            rows.map(_fromRow).toList(growable: false));
  }

  static DailyStep _fromRow(DailyStepRow row) {
    return DailyStep(
      date: row.date,
      steps: row.steps,
      distanceMeters: row.distanceMeters,
      calories: row.calories,
      activeMinutes: row.activeMinutes,
      source: DailyStepSource.values.firstWhere(
        (DailyStepSource s) => s.name == row.source,
        orElse: () => DailyStepSource.pedometer,
      ),
      updatedAt: row.updatedAt,
    );
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}

/// Repository facade used by feature code & background tasks.
class StepsRepository {
  StepsRepository(this._source, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final StepsDataSource _source;
  final DateTime Function() _clock;

  /// Privacy gate: never read pedometer history older than this many
  /// days before the app's install date.
  static const int privacyWindowDays = 30;

  Future<void> recordTick({
    required int totalStepsToday,
    required double weightKg,
    DailyStepSource source = DailyStepSource.pedometer,
    int activeMinutesDelta = 0,
  }) async {
    final DateTime now = _clock();
    final DateTime today = _dateOnly(now);
    final DailyStep? existing = await _source.forDate(today);
    final int safeSteps = totalStepsToday < 0 ? 0 : totalStepsToday;
    final double distance = safeSteps * 0.762; // average stride (m)
    final double calories = safeSteps * 0.04 * (weightKg / 70).clamp(0.6, 1.6);
    final int active = (existing?.activeMinutes ?? 0) + activeMinutesDelta;
    await _source.upsert(
      DailyStep(
        date: today,
        steps: safeSteps,
        distanceMeters: distance,
        calories: calories,
        activeMinutes: active,
        source: source,
        updatedAt: now,
      ),
    );
  }

  /// Insert a `health` package row, used for HealthKit / Health Connect
  /// backfill. Applies the [privacyWindowDays] gate.
  Future<bool> backfillFromHealth({
    required DateTime date,
    required int steps,
    required DateTime installDate,
    DailyStepSource source = DailyStepSource.healthKit,
    double distanceMeters = 0,
    double calories = 0,
    int activeMinutes = 0,
  }) async {
    final DateTime day = _dateOnly(date);
    final DateTime earliest = _dateOnly(installDate)
        .subtract(const Duration(days: privacyWindowDays));
    if (day.isBefore(earliest)) return false;
    await _source.upsert(
      DailyStep(
        date: day,
        steps: steps,
        distanceMeters: distanceMeters,
        calories: calories,
        activeMinutes: activeMinutes,
        source: source,
        updatedAt: _clock(),
      ),
    );
    return true;
  }

  /// Today's deduped total (max across sources).
  Future<DailyStep?> today() async {
    final DateTime t = _dateOnly(_clock());
    final List<DailyStep> rows = await _source.rangeByDate(t, t);
    return dedupe(rows)[t];
  }

  /// Weekly chart series — 7 days ending today (oldest first).
  Future<List<DailyStep>> last7Days() async {
    final DateTime end = _dateOnly(_clock());
    final DateTime start = end.subtract(const Duration(days: 6));
    final List<DailyStep> rows = await _source.rangeByDate(start, end);
    final Map<DateTime, DailyStep> byDay = dedupe(rows);
    return List<DailyStep>.generate(7, (int i) {
      final DateTime d = start.add(Duration(days: i));
      return byDay[d] ??
          DailyStep(
            date: d,
            steps: 0,
            source: DailyStepSource.pedometer,
            updatedAt: _clock(),
          );
    });
  }

  Stream<List<DailyStep>> watchLast7Days() {
    final DateTime end = _dateOnly(_clock());
    final DateTime start = end.subtract(const Duration(days: 6));
    return _source.watchRange(start, end).map((List<DailyStep> rows) {
      final Map<DateTime, DailyStep> byDay = dedupe(rows);
      return List<DailyStep>.generate(7, (int i) {
        final DateTime d = start.add(Duration(days: i));
        return byDay[d] ??
            DailyStep(
              date: d,
              steps: 0,
              source: DailyStepSource.pedometer,
              updatedAt: _clock(),
            );
      });
    });
  }

  /// Cross-device dedupe: keep highest step count per day.
  /// Public for testing.
  static Map<DateTime, DailyStep> dedupe(List<DailyStep> rows) {
    final Map<DateTime, DailyStep> out = <DateTime, DailyStep>{};
    for (final DailyStep row in rows) {
      final DateTime d = _dateOnly(row.date);
      final DailyStep? current = out[d];
      if (current == null || row.steps > current.steps) {
        out[d] = row;
      }
    }
    return out;
  }

  /// Current streak = consecutive days (back from today) where steps
  /// >= [goal]. Today counts if it already crosses goal, but does NOT
  /// break the streak when today is partial and below goal.
  static int currentStreak({
    required List<DailyStep> last30,
    required int goal,
    required DateTime now,
  }) {
    final DateTime today = _dateOnly(now);
    final Map<DateTime, int> byDay = <DateTime, int>{};
    for (final DailyStep s in last30) {
      final DateTime d = _dateOnly(s.date);
      byDay[d] = (byDay[d] ?? 0) > s.steps ? byDay[d]! : s.steps;
    }
    int streak = 0;
    DateTime cursor = today;
    // If today hasn't reached goal yet, don't count it but don't break.
    if ((byDay[today] ?? 0) < goal) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    while ((byDay[cursor] ?? 0) >= goal && streak < last30.length + 1) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Longest streak in [rows]. Order-independent.
  static int longestStreak({
    required List<DailyStep> rows,
    required int goal,
  }) {
    if (rows.isEmpty) return 0;
    final Map<DateTime, int> byDay = <DateTime, int>{};
    for (final DailyStep s in rows) {
      final DateTime d = _dateOnly(s.date);
      byDay[d] = (byDay[d] ?? 0) > s.steps ? byDay[d]! : s.steps;
    }
    final List<DateTime> sorted = byDay.keys.toList()..sort();
    int best = 0;
    int current = 0;
    DateTime? prev;
    for (final DateTime d in sorted) {
      if (byDay[d]! < goal) {
        current = 0;
        prev = d;
        continue;
      }
      if (prev == null || d.difference(prev).inDays == 1) {
        current++;
      } else {
        current = 1;
      }
      if (current > best) best = current;
      prev = d;
    }
    return best;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
