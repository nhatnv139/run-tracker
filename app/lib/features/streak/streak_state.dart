import 'package:flutter/foundation.dart';

/// Snapshot of the streak engine — pure data + helpers consumed by the UI.
@immutable
class StreakState {
  const StreakState({
    required this.currentDays,
    required this.longestDays,
    required this.freezesRemaining,
    required this.lastRunDate,
    required this.lastBrokenDays,
    required this.isActive,
    required this.frozenToday,
    required this.weeklyFreezeGrantedAt,
    required this.monthlyFreezesBought,
  });

  const StreakState.initial()
      : currentDays = 0,
        longestDays = 0,
        freezesRemaining = 0,
        lastRunDate = null,
        lastBrokenDays = 0,
        isActive = false,
        frozenToday = false,
        weeklyFreezeGrantedAt = null,
        monthlyFreezesBought = 0;

  /// Active streak length, in days.
  final int currentDays;
  final int longestDays;

  /// Available freezes that can be auto-applied or manually consumed.
  final int freezesRemaining;

  /// Last calendar day (local time, midnight-truncated) the user ran.
  final DateTime? lastRunDate;

  /// Length of the streak that broke just before — used for Comeback King.
  final int lastBrokenDays;

  /// True when no full calendar day has elapsed without a run.
  final bool isActive;

  /// True if today's slot is filled by a freeze (no run needed).
  final bool frozenToday;

  /// Last date on which the auto-grant 2-freezes-per-week ran.
  final DateTime? weeklyFreezeGrantedAt;

  /// How many freezes user purchased with coin in the current month.
  final int monthlyFreezesBought;

  StreakState copyWith({
    int? currentDays,
    int? longestDays,
    int? freezesRemaining,
    DateTime? lastRunDate,
    int? lastBrokenDays,
    bool? isActive,
    bool? frozenToday,
    DateTime? weeklyFreezeGrantedAt,
    int? monthlyFreezesBought,
    bool clearLastRunDate = false,
  }) {
    return StreakState(
      currentDays: currentDays ?? this.currentDays,
      longestDays: longestDays ?? this.longestDays,
      freezesRemaining: freezesRemaining ?? this.freezesRemaining,
      lastRunDate:
          clearLastRunDate ? null : (lastRunDate ?? this.lastRunDate),
      lastBrokenDays: lastBrokenDays ?? this.lastBrokenDays,
      isActive: isActive ?? this.isActive,
      frozenToday: frozenToday ?? this.frozenToday,
      weeklyFreezeGrantedAt:
          weeklyFreezeGrantedAt ?? this.weeklyFreezeGrantedAt,
      monthlyFreezesBought:
          monthlyFreezesBought ?? this.monthlyFreezesBought,
    );
  }
}
