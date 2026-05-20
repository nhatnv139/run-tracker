import 'package:runvie/features/streak/streak_state.dart';

/// Pure streak math. All inputs explicit so unit tests can pin time without
/// any side effects. Days are compared as local midnight-truncated dates.
class StreakCalculator {
  const StreakCalculator({
    this.maxFreezesHeld = 5,
    this.weeklyFreezeGrant = 2,
    this.monthlyBuyCap = 5,
    this.freezeBuyCost = 50,
    this.comebackWindowDays = 7,
  });

  final int maxFreezesHeld;

  /// Number of freezes auto-granted at the start of each ISO week.
  final int weeklyFreezeGrant;

  /// Max freezes a user can BUY per calendar month.
  final int monthlyBuyCap;

  /// Coin cost per bought freeze.
  final int freezeBuyCost;

  /// "Comeback King" — broken streak rebuilt within this many days.
  final int comebackWindowDays;

  /// Truncate to local-midnight.
  static DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Number of full days between two midnight-truncated dates.
  static int _daysBetween(DateTime a, DateTime b) {
    return _dayOf(b).difference(_dayOf(a)).inDays;
  }

  /// Apply auto weekly grant if a fresh ISO week has started since the
  /// previous grant.
  StreakState applyWeeklyGrant(StreakState s, DateTime now) {
    final DateTime today = _dayOf(now);
    if (s.weeklyFreezeGrantedAt != null) {
      final DateTime last = _dayOf(s.weeklyFreezeGrantedAt!);
      final int daysSince = today.difference(last).inDays;
      if (daysSince < 7) return s;
    }
    final int next =
        (s.freezesRemaining + weeklyFreezeGrant).clamp(0, maxFreezesHeld);
    return s.copyWith(
      freezesRemaining: next,
      weeklyFreezeGrantedAt: today,
    );
  }

  /// Process a completed run on [runDate]. Increments the streak when the
  /// run lands on a new day or extends a still-active streak.
  StreakState onRunCompleted(StreakState s, DateTime runDate) {
    final DateTime today = _dayOf(runDate);
    if (s.lastRunDate == null) {
      // First ever run.
      return s.copyWith(
        currentDays: 1,
        longestDays: s.longestDays < 1 ? 1 : s.longestDays,
        isActive: true,
        lastRunDate: today,
        frozenToday: false,
      );
    }
    final int gap = today.difference(_dayOf(s.lastRunDate!)).inDays;
    if (gap == 0) {
      // Same day — second run does not advance the streak.
      return s;
    } else if (gap == 1) {
      final int next = s.currentDays + 1;
      return s.copyWith(
        currentDays: next,
        longestDays: next > s.longestDays ? next : s.longestDays,
        isActive: true,
        lastRunDate: today,
        frozenToday: false,
      );
    }
    // Gap >= 2 -> streak broke before today (freeze handling done by tick).
    final int rebuiltFromBreak = s.lastBrokenDays;
    final bool comeback =
        rebuiltFromBreak > 0 && gap - 1 <= comebackWindowDays;
    return s.copyWith(
      currentDays: 1,
      isActive: true,
      lastRunDate: today,
      frozenToday: false,
      // Preserve lastBrokenDays so the badge engine can award Comeback King
      // on the very next save; cleared by the consumer once awarded.
      lastBrokenDays: comeback ? rebuiltFromBreak : 0,
    );
  }

  /// Daily roll-over. Should run once per app launch at startup with
  /// `now = DateTime.now()`. Burns freezes to cover gaps; breaks the streak
  /// when freezes run out.
  StreakState tick(StreakState s, DateTime now) {
    StreakState state = applyWeeklyGrant(s, now);
    if (state.lastRunDate == null || !state.isActive) return state;
    final int gap = _daysBetween(state.lastRunDate!, now);
    if (gap <= 0) return state; // ran today already
    if (gap == 1) {
      // Yesterday ran, today not yet — streak still in window. No action.
      return state.copyWith(frozenToday: false);
    }
    // Gap >= 2 means at least one missed day. Try to cover with freezes.
    int missed = gap - 1;
    int freezesAvail = state.freezesRemaining;
    int currentDays = state.currentDays;
    DateTime lastRun = state.lastRunDate!;
    while (missed > 0 && freezesAvail > 0) {
      freezesAvail -= 1;
      missed -= 1;
      currentDays += 1;
      lastRun = lastRun.add(const Duration(days: 1));
    }
    if (missed > 0) {
      // Streak breaks.
      return state.copyWith(
        lastBrokenDays: currentDays,
        currentDays: 0,
        isActive: false,
        freezesRemaining: freezesAvail,
        frozenToday: false,
        // Keep lastRunDate for "days since last run" UI; do not clear.
      );
    }
    // Fully covered by freezes — keep streak alive.
    return state.copyWith(
      freezesRemaining: freezesAvail,
      currentDays: currentDays,
      longestDays:
          currentDays > state.longestDays ? currentDays : state.longestDays,
      lastRunDate: lastRun,
      frozenToday: true,
      isActive: true,
    );
  }

  /// Can the user buy another freeze with RunCoin this calendar month?
  bool canBuyFreeze(StreakState s) {
    return s.monthlyFreezesBought < monthlyBuyCap &&
        s.freezesRemaining < maxFreezesHeld;
  }

  StreakState buyFreeze(StreakState s) {
    if (!canBuyFreeze(s)) return s;
    return s.copyWith(
      freezesRemaining: s.freezesRemaining + 1,
      monthlyFreezesBought: s.monthlyFreezesBought + 1,
    );
  }

  /// Reset the bought-counter at the start of a new calendar month — to be
  /// called by `tick` consumers when month changes.
  StreakState resetMonthlyBuysIfNeeded(StreakState s, DateTime now,
      DateTime? lastResetAt) {
    if (lastResetAt == null) return s;
    if (now.year != lastResetAt.year || now.month != lastResetAt.month) {
      return s.copyWith(monthlyFreezesBought: 0);
    }
    return s;
  }

  /// True when the user is still streaking but has NOT run yet today AND it
  /// is past 20:00 local. Hook for the warning push notification.
  bool shouldSendWarningPush(StreakState s, DateTime now) {
    if (!s.isActive || s.currentDays < 1) return false;
    if (s.lastRunDate == null) return false;
    final DateTime today = _dayOf(now);
    if (_dayOf(s.lastRunDate!).isAtSameMomentAs(today)) return false;
    return now.hour >= 20;
  }
}
