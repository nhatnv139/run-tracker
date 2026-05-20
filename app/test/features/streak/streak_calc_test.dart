import 'package:flutter_test/flutter_test.dart';

import 'package:runvie/features/streak/streak_calc.dart';
import 'package:runvie/features/streak/streak_state.dart';

void main() {
  const StreakCalculator calc = StreakCalculator();

  StreakState seed({
    int currentDays = 0,
    int longestDays = 0,
    int freezesRemaining = 0,
    DateTime? lastRunDate,
    int lastBrokenDays = 0,
    bool isActive = false,
    DateTime? weeklyFreezeGrantedAt,
    int monthlyFreezesBought = 0,
  }) {
    return StreakState(
      currentDays: currentDays,
      longestDays: longestDays,
      freezesRemaining: freezesRemaining,
      lastRunDate: lastRunDate,
      lastBrokenDays: lastBrokenDays,
      isActive: isActive,
      frozenToday: false,
      weeklyFreezeGrantedAt: weeklyFreezeGrantedAt,
      monthlyFreezesBought: monthlyFreezesBought,
    );
  }

  group('onRunCompleted', () {
    test('first ever run starts streak at 1', () {
      final StreakState s = calc.onRunCompleted(
        seed(),
        DateTime(2026, 1, 1, 8),
      );
      expect(s.currentDays, 1);
      expect(s.longestDays, 1);
      expect(s.isActive, true);
    });

    test('second run same day does not advance', () {
      final DateTime day = DateTime(2026, 1, 1);
      final StreakState s1 = calc.onRunCompleted(seed(), day);
      final StreakState s2 = calc.onRunCompleted(s1, day.add(const Duration(hours: 4)));
      expect(s2.currentDays, 1);
    });

    test('next-day run extends streak', () {
      final StreakState s1 = calc.onRunCompleted(seed(), DateTime(2026, 1, 1));
      final StreakState s2 = calc.onRunCompleted(s1, DateTime(2026, 1, 2));
      expect(s2.currentDays, 2);
      expect(s2.longestDays, 2);
    });

    test('comeback after broken streak triggers comeback marker', () {
      // Seed: had a 10-day streak that broke, gap = 3 days, now a new run.
      final StreakState start = seed(
        lastRunDate: DateTime(2026, 1, 1),
        lastBrokenDays: 10,
        isActive: false,
      );
      final StreakState after = calc.onRunCompleted(
        start,
        DateTime(2026, 1, 5),
      );
      expect(after.currentDays, 1);
      // lastBrokenDays preserved so badge engine can pick it up
      expect(after.lastBrokenDays, 10);
    });
  });

  group('tick / freeze application', () {
    test('1-day gap keeps streak alive without burning freeze', () {
      final StreakState s = seed(
        currentDays: 5,
        longestDays: 5,
        freezesRemaining: 2,
        lastRunDate: DateTime(2026, 1, 1),
        isActive: true,
      );
      final StreakState after = calc.tick(s, DateTime(2026, 1, 2, 9));
      expect(after.currentDays, 5);
      expect(after.freezesRemaining, 2);
      expect(after.isActive, true);
    });

    test('2-day gap burns one freeze and keeps streak alive', () {
      final StreakState s = seed(
        currentDays: 5,
        longestDays: 5,
        freezesRemaining: 2,
        lastRunDate: DateTime(2026, 1, 1),
        isActive: true,
      );
      final StreakState after = calc.tick(s, DateTime(2026, 1, 3, 9));
      expect(after.currentDays, 6);
      expect(after.freezesRemaining, 1);
      expect(after.frozenToday, true);
      expect(after.isActive, true);
    });

    test('streak breaks when freezes run out', () {
      final StreakState s = seed(
        currentDays: 7,
        longestDays: 7,
        freezesRemaining: 1,
        lastRunDate: DateTime(2026, 1, 1),
        isActive: true,
      );
      // 4-day gap means 3 missed days, only 1 freeze -> breaks
      final StreakState after = calc.tick(s, DateTime(2026, 1, 5, 9));
      expect(after.isActive, false);
      expect(after.currentDays, 0);
      expect(after.lastBrokenDays, 8); // 7 + 1 freeze covered then broke
      expect(after.freezesRemaining, 0);
    });
  });

  group('weekly freeze grant', () {
    test('grants 2 freezes once per week, capped at 5', () {
      final StreakState s = seed(freezesRemaining: 3);
      final StreakState after = calc.applyWeeklyGrant(s, DateTime(2026, 1, 5));
      expect(after.freezesRemaining, 5);
      // Re-running same day does not double-grant
      final StreakState again =
          calc.applyWeeklyGrant(after, DateTime(2026, 1, 5));
      expect(again.freezesRemaining, 5);
    });
  });

  group('buy freeze', () {
    test('respects monthly cap of 5', () {
      StreakState s = seed(freezesRemaining: 0);
      for (int i = 0; i < 5; i++) {
        expect(calc.canBuyFreeze(s), true);
        s = calc.buyFreeze(s);
      }
      expect(s.monthlyFreezesBought, 5);
      expect(calc.canBuyFreeze(s), false);
    });
  });

  group('warning push', () {
    test('triggers when active streak and past 20h with no run today', () {
      final StreakState s = seed(
        currentDays: 3,
        isActive: true,
        lastRunDate: DateTime(2026, 1, 4),
      );
      expect(calc.shouldSendWarningPush(s, DateTime(2026, 1, 5, 21)), true);
    });

    test('does not trigger if ran today', () {
      final StreakState s = seed(
        currentDays: 3,
        isActive: true,
        lastRunDate: DateTime(2026, 1, 5, 7),
      );
      expect(calc.shouldSendWarningPush(s, DateTime(2026, 1, 5, 21)), false);
    });

    test('does not trigger before 20h', () {
      final StreakState s = seed(
        currentDays: 3,
        isActive: true,
        lastRunDate: DateTime(2026, 1, 4),
      );
      expect(calc.shouldSendWarningPush(s, DateTime(2026, 1, 5, 19)), false);
    });
  });
}
