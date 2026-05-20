import 'package:flutter_test/flutter_test.dart';

import 'package:runvie/data/models/badge.dart';
import 'package:runvie/features/badges/badge_criteria.dart';
import 'package:runvie/services/run_events.dart';

BadgeModel _badge({
  required String id,
  required BadgeCriteriaType type,
  required double value,
  int? hourStart,
  int? hourEnd,
  bool hidden = false,
}) {
  return BadgeModel(
    id: id,
    slug: id,
    nameVi: id,
    nameEn: id,
    descriptionVi: '',
    descriptionEn: '',
    category: BadgeCategory.distance,
    tier: BadgeTier.bronze,
    criteriaType: type,
    criteriaValue: value,
    criteriaHourStart: hourStart,
    criteriaHourEnd: hourEnd,
    isHidden: hidden,
  );
}

UserActivityStats _stats({
  double lifetimeKm = 0,
  int streak = 0,
  int broken = 0,
  List<int>? hours,
}) {
  return UserActivityStats(
    lifetimeKm: lifetimeKm,
    currentStreakDays: streak,
    brokenStreakDaysLast: broken,
    runsByHour: hours ?? List<int>.filled(24, 0),
  );
}

RunSavedEvent _run({
  double km = 10,
  int paceSec = 0,
}) {
  final DateTime now = DateTime(2026, 5, 1, 7);
  return RunSavedEvent(
    activityId: 'a1',
    userId: 'u1',
    distanceMeters: km * 1000,
    durationSec: paceSec > 0 ? (paceSec * km).round() : 3600,
    startedAt: now,
    endedAt: now.add(const Duration(hours: 1)),
    avgPaceSecPerKm: paceSec.toDouble(),
  );
}

void main() {
  const BadgeCriteriaEvaluator evalr = BadgeCriteriaEvaluator();

  group('distance criteria', () {
    test('single run progress', () {
      final BadgeModel b = _badge(
        id: 'b',
        type: BadgeCriteriaType.distanceSingleKm,
        value: 5,
      );
      expect(
        evalr.progressFor(b, stats: _stats(), latestRun: _run(km: 3)),
        closeTo(0.6, 1e-6),
      );
      expect(
        evalr.isSatisfied(b, stats: _stats(), latestRun: _run(km: 5)),
        true,
      );
    });

    test('lifetime total progress', () {
      final BadgeModel b = _badge(
        id: 'b',
        type: BadgeCriteriaType.distanceTotalKm,
        value: 100,
      );
      expect(evalr.progressFor(b, stats: _stats(lifetimeKm: 50)),
          closeTo(0.5, 1e-6));
      expect(evalr.isSatisfied(b, stats: _stats(lifetimeKm: 200)), true);
    });
  });

  group('streak criteria', () {
    test('progress reflects current days', () {
      final BadgeModel b = _badge(
        id: 'b',
        type: BadgeCriteriaType.streakDays,
        value: 30,
      );
      expect(evalr.progressFor(b, stats: _stats(streak: 15)),
          closeTo(0.5, 1e-6));
    });
  });

  group('time-of-day', () {
    test('counts runs in window', () {
      final List<int> hours = List<int>.filled(24, 0);
      hours[5] = 10; // sunrise runs
      hours[6] = 12;
      final BadgeModel sunrise = _badge(
        id: 'sunrise',
        type: BadgeCriteriaType.timeOfDay,
        value: 30,
        hourStart: 4,
        hourEnd: 7,
      );
      expect(
        evalr.progressFor(sunrise, stats: _stats(hours: hours)),
        closeTo(22 / 30, 1e-6),
      );
    });

    test('handles wrap-around (22h..2h)', () {
      final List<int> hours = List<int>.filled(24, 0);
      hours[23] = 5;
      hours[1] = 5;
      final BadgeModel nightOwl = _badge(
        id: 'owl',
        type: BadgeCriteriaType.timeOfDay,
        value: 5,
        hourStart: 22,
        hourEnd: 2,
      );
      expect(evalr.isSatisfied(nightOwl, stats: _stats(hours: hours)), true);
    });
  });

  group('pace criteria', () {
    test('sub-5K pace satisfied at exact value', () {
      final BadgeModel sub = _badge(
        id: 'sub25',
        type: BadgeCriteriaType.paceSub5K,
        value: 300,
      );
      expect(
        evalr.isSatisfied(sub, stats: _stats(), latestRun: _run(km: 5, paceSec: 290)),
        true,
      );
      expect(
        evalr.isSatisfied(sub, stats: _stats(), latestRun: _run(km: 5, paceSec: 310)),
        false,
      );
    });
  });

  group('exact distance hidden', () {
    test('3.14km hits within tolerance', () {
      final BadgeModel pi = _badge(
        id: 'pi',
        type: BadgeCriteriaType.exactDistance,
        value: 3.14,
        hidden: true,
      );
      expect(
        evalr.isSatisfied(pi, stats: _stats(), latestRun: _run(km: 3.15)),
        true,
      );
      expect(
        evalr.isSatisfied(pi, stats: _stats(), latestRun: _run(km: 3.40)),
        false,
      );
    });
  });

  group('comeback king', () {
    test('triggers only after a broken streak', () {
      final BadgeModel cb = _badge(
        id: 'cb',
        type: BadgeCriteriaType.comebackKing,
        value: 1,
      );
      expect(
        evalr.isSatisfied(cb, stats: _stats(streak: 1, broken: 10)),
        true,
      );
      expect(evalr.isSatisfied(cb, stats: _stats(streak: 1)), false);
    });
  });
}
