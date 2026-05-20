import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runvie/data/models/coin_transaction.dart';
import 'package:runvie/data/repositories/coin_repository.dart';
import 'package:runvie/services/run_events.dart';
import 'package:runvie/services/supabase_service.dart';

/// Wraps [CoinRepository] state so the UI can use `watch` with rebuilds.
class CoinWalletState {
  const CoinWalletState({
    required this.balance,
    required this.recent,
    required this.earnedToday,
  });

  const CoinWalletState.empty()
      : balance = 0,
        recent = const <CoinTransaction>[],
        earnedToday = 0;

  final int balance;
  final List<CoinTransaction> recent;
  final int earnedToday;
}

class CoinWalletController extends StateNotifier<CoinWalletState> {
  CoinWalletController({
    required this.repo,
    required this.calculator,
  }) : super(const CoinWalletState.empty());

  final CoinRepository repo;
  final CoinEarnCalculator calculator;

  /// Re-derive [earnedToday] from the ledger so the daily cap is enforced
  /// across cold-starts.
  int _computeEarnedToday() {
    final DateTime today = DateTime.now();
    final DateTime startOfDay = DateTime(today.year, today.month, today.day);
    return repo.ledger
        .where((CoinTransaction t) =>
            t.createdAt.isAfter(startOfDay) &&
            t.amount > 0 &&
            t.reason == CoinTxnReason.runKm)
        .fold<int>(0, (int sum, CoinTransaction t) => sum + t.amount);
  }

  Future<void> hydrate({required String userId}) async {
    await repo.getBalance(userId: userId);
    state = CoinWalletState(
      balance: repo.balance,
      recent: await repo.history(userId: userId),
      earnedToday: _computeEarnedToday(),
    );
  }

  Future<void> creditRun({
    required String userId,
    required RunSavedEvent event,
    int userLevel = 1,
  }) async {
    final int earned = calculator.earningsForRun(
      distanceKm: event.distanceKm,
      level: userLevel,
      earnedTodaySoFar: state.earnedToday,
    );
    if (earned <= 0) return;
    await repo.append(
      userId: userId,
      amount: earned,
      reason: CoinTxnReason.runKm,
      activityId: event.activityId,
      note: '${event.distanceKm.toStringAsFixed(2)}km',
    );
    state = CoinWalletState(
      balance: repo.balance,
      recent: await repo.history(userId: userId),
      earnedToday: state.earnedToday + earned,
    );
  }

  Future<RedeemedVoucher?> redeem({
    required String userId,
    required VoucherOffer offer,
  }) async {
    try {
      final RedeemedVoucher v = await repo.redeem(userId: userId, offer: offer);
      state = CoinWalletState(
        balance: repo.balance,
        recent: await repo.history(userId: userId),
        earnedToday: state.earnedToday,
      );
      return v;
    } catch (e) {
      debugPrint('redeem failed: $e');
      rethrow;
    }
  }
}

final StateNotifierProvider<CoinWalletController, CoinWalletState>
    coinWalletControllerProvider =
    StateNotifierProvider<CoinWalletController, CoinWalletState>((Ref ref) {
  final CoinWalletController c = CoinWalletController(
    repo: ref.watch(coinRepositoryProvider),
    calculator: ref.watch(coinEarnCalculatorProvider),
  );
  final String? uid = SupabaseService.instance.currentUser?.id;
  if (uid != null) {
    unawaited(c.hydrate(userId: uid));
  }
  // Bridge run events -> coin earning.
  ref.listen<AsyncValue<RunSavedEvent>>(runEventsStreamProvider,
      (AsyncValue<RunSavedEvent>? prev, AsyncValue<RunSavedEvent> next) {
    next.whenData((RunSavedEvent e) {
      unawaited(c.creditRun(userId: e.userId, event: e));
    });
  });
  return c;
});

final FutureProvider<List<VoucherOffer>> voucherCatalogProvider =
    FutureProvider<List<VoucherOffer>>((Ref ref) async {
  return ref.watch(coinRepositoryProvider).getVoucherCatalog();
});
