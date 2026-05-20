import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runvie/data/models/badge.dart';
import 'package:runvie/data/repositories/badge_repository.dart';
import 'package:runvie/features/badges/badge_criteria.dart';
import 'package:runvie/services/run_events.dart';
import 'package:runvie/services/supabase_service.dart';

/// Catalog provider — loads 62 seed badges once per session.
final FutureProvider<List<BadgeModel>> badgeCatalogProvider =
    FutureProvider<List<BadgeModel>>((Ref ref) async {
  final BadgeRepository repo = ref.watch(badgeRepositoryProvider);
  return repo.getCatalog();
});

/// Earned badges for the signed-in user.
final FutureProvider<List<UserBadge>> earnedBadgesProvider =
    FutureProvider<List<UserBadge>>((Ref ref) async {
  final String? uid = SupabaseService.instance.currentUser?.id;
  if (uid == null) return const <UserBadge>[];
  return ref.watch(badgeRepositoryProvider).getEarned(userId: uid);
});

final Provider<BadgeCriteriaEvaluator> badgeCriteriaEvaluatorProvider =
    Provider<BadgeCriteriaEvaluator>((Ref ref) => const BadgeCriteriaEvaluator());

/// Stream-style provider that the gallery / detail / celebration modal
/// listen to. Buffers any unread celebrations.
class BadgeCelebrationQueue extends StateNotifier<List<BadgeModel>> {
  BadgeCelebrationQueue() : super(<BadgeModel>[]);

  void enqueue(Iterable<BadgeModel> badges) {
    if (badges.isEmpty) return;
    state = <BadgeModel>[...state, ...badges];
  }

  BadgeModel? popNext() {
    if (state.isEmpty) return null;
    final BadgeModel first = state.first;
    state = state.skip(1).toList(growable: false);
    return first;
  }

  void clear() => state = <BadgeModel>[];
}

final StateNotifierProvider<BadgeCelebrationQueue, List<BadgeModel>>
    badgeCelebrationProvider =
    StateNotifierProvider<BadgeCelebrationQueue, List<BadgeModel>>(
  (Ref ref) => BadgeCelebrationQueue(),
);

/// Listener that wires the run-events bus to badge awarding. Activate this
/// once during app start by reading the provider so the listener stays
/// attached.
final Provider<void> badgeAwardListenerProvider = Provider<void>((Ref ref) {
  ref.listen<AsyncValue<RunSavedEvent>>(
    runEventsStreamProvider,
    (AsyncValue<RunSavedEvent>? prev, AsyncValue<RunSavedEvent> next) {
      next.whenData((RunSavedEvent event) async {
        try {
          final List<BadgeModel> newBadges = await ref
              .read(badgeRepositoryProvider)
              .awardForActivity(
                userId: event.userId,
                activityId: event.activityId,
              );
          if (newBadges.isNotEmpty) {
            ref.read(badgeCelebrationProvider.notifier).enqueue(newBadges);
            // Invalidate the earned list so the gallery refreshes.
            ref.invalidate(earnedBadgesProvider);
          }
        } catch (e) {
          debugPrint('badge award failed: $e');
        }
      });
    },
  );
});
