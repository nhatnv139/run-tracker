import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runvie/data/repositories/subscription_repository.dart';
import 'package:runvie/services/iap_service.dart';

/// Top-level subscription state. The UI switches on [SubscriptionStatus] and
/// the feature-gate widget reads [snapshot.isPremium] / trial info.
enum SubscriptionStatus {
  free,
  trial,
  plus,
  pro,
  family,
  cancelled,
}

@immutable
class SubscriptionState {
  const SubscriptionState({
    required this.status,
    required this.snapshot,
    required this.loading,
    this.error,
  });

  const SubscriptionState.initial()
      : status = SubscriptionStatus.free,
        snapshot = const SubscriptionSnapshot.free(),
        loading = false,
        error = null;

  final SubscriptionStatus status;
  final SubscriptionSnapshot snapshot;
  final bool loading;
  final String? error;

  bool get isPremium =>
      status != SubscriptionStatus.free &&
      status != SubscriptionStatus.cancelled;

  int get trialDaysLeft => snapshot.trialDaysLeft;

  SubscriptionState copyWith({
    SubscriptionStatus? status,
    SubscriptionSnapshot? snapshot,
    bool? loading,
    String? error,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      snapshot: snapshot ?? this.snapshot,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  static SubscriptionStatus statusFromSnapshot(SubscriptionSnapshot s) {
    if (s.isInTrial) return SubscriptionStatus.trial;
    if (s.isCancelled) return SubscriptionStatus.cancelled;
    switch (s.tier) {
      case SubscriptionTier.free:
        return SubscriptionStatus.free;
      case SubscriptionTier.plus:
        return SubscriptionStatus.plus;
      case SubscriptionTier.pro:
        return SubscriptionStatus.pro;
      case SubscriptionTier.family:
        return SubscriptionStatus.family;
    }
  }
}

class SubscriptionController extends StateNotifier<SubscriptionState> {
  SubscriptionController({required SubscriptionRepository repo})
      : _repo = repo,
        super(const SubscriptionState.initial());

  final SubscriptionRepository _repo;

  Future<void> refresh() async {
    state = state.copyWith(loading: true);
    try {
      final SubscriptionSnapshot s = await _repo.current();
      state = state.copyWith(
        loading: false,
        snapshot: s,
        status: SubscriptionState.statusFromSnapshot(s),
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<bool> purchase(IapPackage package) async {
    state = state.copyWith(loading: true);
    try {
      final SubscriptionSnapshot s = await _repo.purchase(package);
      state = SubscriptionState(
        status: SubscriptionState.statusFromSnapshot(s),
        snapshot: s,
        loading: false,
      );
      return true;
    } on PurchaseException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> restore() async {
    state = state.copyWith(loading: true);
    try {
      final SubscriptionSnapshot s = await _repo.restore();
      state = SubscriptionState(
        status: SubscriptionState.statusFromSnapshot(s),
        snapshot: s,
        loading: false,
      );
      return s.isPremium;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  /// Force a downgrade — used by the reverse-trial expiry hook.
  void debugDowngrade() {
    state = SubscriptionState(
      status: SubscriptionStatus.free,
      snapshot: const SubscriptionSnapshot.free(),
      loading: false,
    );
  }
}

final StateNotifierProvider<SubscriptionController, SubscriptionState>
    subscriptionControllerProvider =
    StateNotifierProvider<SubscriptionController, SubscriptionState>(
  (Ref ref) {
    final SubscriptionController c = SubscriptionController(
      repo: ref.watch(subscriptionRepositoryProvider),
    );
    unawaited(c.refresh());
    return c;
  },
);

/// Helper provider — read this for a synchronous "premium?" answer.
final Provider<bool> isPremiumProvider = Provider<bool>((Ref ref) {
  return ref.watch(subscriptionControllerProvider).isPremium;
});

final FutureProvider<List<IapPackage>> iapOfferingsProvider =
    FutureProvider<List<IapPackage>>((Ref ref) async {
  return ref.watch(subscriptionRepositoryProvider).offerings();
});
