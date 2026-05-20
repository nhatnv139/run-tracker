import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runvie/data/models/coin_transaction.dart';
import 'package:runvie/data/repositories/coin_repository.dart';
import 'package:runvie/features/streak/streak_calc.dart';
import 'package:runvie/features/streak/streak_state.dart';
import 'package:runvie/services/run_events.dart';

final Provider<StreakCalculator> streakCalculatorProvider =
    Provider<StreakCalculator>((Ref ref) => const StreakCalculator());

/// In-memory streak controller. Persistence to Drift/Supabase is a TODO
/// hook — backed by the local source of truth so it is testable without
/// touching disk.
class StreakController extends StateNotifier<StreakState> {
  StreakController({
    required this.calculator,
    StreakState? initial,
  }) : super(initial ?? const StreakState.initial());

  final StreakCalculator calculator;

  /// Mounted once at app start.
  void tick({DateTime? now}) {
    state = calculator.tick(state, now ?? DateTime.now());
  }

  void onRun(DateTime runDate) {
    state = calculator.onRunCompleted(state, runDate);
  }

  /// Spend 50 RunCoin to acquire another freeze (cap 5/month).
  Future<bool> buyFreeze({
    required String userId,
    required CoinRepository coinRepo,
  }) async {
    if (!calculator.canBuyFreeze(state)) return false;
    if (coinRepo.balance < calculator.freezeBuyCost) return false;
    await coinRepo.append(
      userId: userId,
      amount: -calculator.freezeBuyCost,
      reason: CoinTxnReason.streakFreezeBuy,
      note: 'Mua dong bang chuoi',
    );
    state = calculator.buyFreeze(state);
    return true;
  }
}

final StateNotifierProvider<StreakController, StreakState>
    streakControllerProvider =
    StateNotifierProvider<StreakController, StreakState>((Ref ref) {
  final StreakController controller = StreakController(
    calculator: ref.watch(streakCalculatorProvider),
  );
  // Tick on creation so the daily roll-over runs immediately.
  controller.tick();
  // Listen for run-saved events and advance the streak. Keep the listener
  // alive for the provider's lifetime.
  ref.listen<AsyncValue<RunSavedEvent>>(runEventsStreamProvider,
      (AsyncValue<RunSavedEvent>? prev, AsyncValue<RunSavedEvent> next) {
    next.whenData((RunSavedEvent e) => controller.onRun(e.endedAt));
  });
  return controller;
});
