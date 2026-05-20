import 'package:runvie/data/models/activity.dart';
import 'package:runvie/data/models/personal_record.dart';

/// Pure functions for computing personal records from a list of activities.
///
/// Designed for ease of unit-testing — no I/O, no async.
class PrDetector {
  PrDetector._();

  /// Computes the full set of PRs implied by [activities]. Activities can be
  /// in any order; output map is keyed by [PrKind].
  static Map<PrKind, PersonalRecord> computeAll(List<Activity> activities) {
    final Map<PrKind, PersonalRecord> result = <PrKind, PersonalRecord>{};
    if (activities.isEmpty) return result;

    // Stable order — oldest first so earliest achievement is recorded
    // on a tie.
    final List<Activity> sorted = <Activity>[...activities]
      ..sort((Activity a, Activity b) => a.startedAt.compareTo(b.startedAt));

    for (final Activity activity in sorted) {
      _applyActivity(activity, result);
    }

    final PersonalRecord? streak = _longestStreak(sorted);
    if (streak != null) {
      result[PrKind.longestStreak] = streak;
    }

    return result;
  }

  /// Detects PRs that [newActivity] establishes *relative* to [existing]
  /// (existing PRs from prior activities). Returns the list of achievements.
  static List<PrAchievement> detect({
    required Activity newActivity,
    required Map<PrKind, PersonalRecord> existing,
    List<Activity> historyIncludingNew = const <Activity>[],
  }) {
    final List<PrAchievement> out = <PrAchievement>[];

    // Time-based PRs — require the activity distance to be >= threshold.
    for (final PrKind kind in <PrKind>[
      PrKind.fastest1k,
      PrKind.fastest5k,
      PrKind.fastest10k,
      PrKind.fastestHalfMarathon,
      PrKind.fastestMarathon,
    ]) {
      final double threshold = kind.distanceThresholdMeters!;
      if (newActivity.distanceMeters + 0.5 < threshold) continue;

      // Best-effort: extrapolate the time taken for `threshold` meters using
      // the average pace. (Real implementation should slice GPS into the
      // exact 1k/5k/etc sub-segment.)
      final double secondsForThreshold =
          newActivity.avgPaceSecPerKm * (threshold / 1000.0);
      final PersonalRecord? prev = existing[kind];
      if (prev == null || secondsForThreshold < prev.value - 0.0001) {
        out.add(PrAchievement(
          kind: kind,
          newValue: secondsForThreshold,
          previousValue: prev?.value,
        ));
      }
    }

    // Longest run
    final PersonalRecord? prevLongest = existing[PrKind.longestRun];
    if (prevLongest == null ||
        newActivity.distanceMeters > prevLongest.value + 0.0001) {
      out.add(PrAchievement(
        kind: PrKind.longestRun,
        newValue: newActivity.distanceMeters,
        previousValue: prevLongest?.value,
      ));
    }

    // Biggest elevation
    if (newActivity.elevationGainM > 0) {
      final PersonalRecord? prevElev = existing[PrKind.biggestElevation];
      if (prevElev == null ||
          newActivity.elevationGainM > prevElev.value + 0.0001) {
        out.add(PrAchievement(
          kind: PrKind.biggestElevation,
          newValue: newActivity.elevationGainM,
          previousValue: prevElev?.value,
        ));
      }
    }

    // Longest streak — recompute over the full history.
    if (historyIncludingNew.isNotEmpty) {
      final PersonalRecord? newStreak = _longestStreak(historyIncludingNew);
      final PersonalRecord? prevStreak = existing[PrKind.longestStreak];
      if (newStreak != null &&
          (prevStreak == null || newStreak.value > prevStreak.value)) {
        out.add(PrAchievement(
          kind: PrKind.longestStreak,
          newValue: newStreak.value,
          previousValue: prevStreak?.value,
        ));
      }
    }

    return out;
  }

  // --- internals -----------------------------------------------------------

  static void _applyActivity(
    Activity activity,
    Map<PrKind, PersonalRecord> result,
  ) {
    for (final PrKind kind in <PrKind>[
      PrKind.fastest1k,
      PrKind.fastest5k,
      PrKind.fastest10k,
      PrKind.fastestHalfMarathon,
      PrKind.fastestMarathon,
    ]) {
      final double threshold = kind.distanceThresholdMeters!;
      if (activity.distanceMeters + 0.5 < threshold) continue;
      final double secondsForThreshold =
          activity.avgPaceSecPerKm * (threshold / 1000.0);
      final PersonalRecord? prev = result[kind];
      if (prev == null || secondsForThreshold < prev.value) {
        result[kind] = PersonalRecord(
          kind: kind,
          value: secondsForThreshold,
          achievedAt: activity.startedAt,
          activityId: activity.id,
        );
      }
    }

    final PersonalRecord? prevLongest = result[PrKind.longestRun];
    if (prevLongest == null ||
        activity.distanceMeters > prevLongest.value) {
      result[PrKind.longestRun] = PersonalRecord(
        kind: PrKind.longestRun,
        value: activity.distanceMeters,
        achievedAt: activity.startedAt,
        activityId: activity.id,
      );
    }

    if (activity.elevationGainM > 0) {
      final PersonalRecord? prevElev = result[PrKind.biggestElevation];
      if (prevElev == null || activity.elevationGainM > prevElev.value) {
        result[PrKind.biggestElevation] = PersonalRecord(
          kind: PrKind.biggestElevation,
          value: activity.elevationGainM,
          achievedAt: activity.startedAt,
          activityId: activity.id,
        );
      }
    }
  }

  static PersonalRecord? _longestStreak(List<Activity> sorted) {
    if (sorted.isEmpty) return null;

    final Set<DateTime> activeDays = sorted
        .map((Activity a) =>
            DateTime(a.startedAt.year, a.startedAt.month, a.startedAt.day))
        .toSet();

    final List<DateTime> orderedDays = activeDays.toList()..sort();

    int bestStreak = 1;
    int curStreak = 1;
    DateTime bestEnd = orderedDays.first;
    DateTime curEnd = orderedDays.first;

    for (int i = 1; i < orderedDays.length; i++) {
      final DateTime prev = orderedDays[i - 1];
      final DateTime cur = orderedDays[i];
      if (cur.difference(prev).inDays == 1) {
        curStreak += 1;
        curEnd = cur;
      } else {
        curStreak = 1;
        curEnd = cur;
      }
      if (curStreak > bestStreak) {
        bestStreak = curStreak;
        bestEnd = curEnd;
      }
    }

    return PersonalRecord(
      kind: PrKind.longestStreak,
      value: bestStreak.toDouble(),
      achievedAt: bestEnd,
    );
  }
}
