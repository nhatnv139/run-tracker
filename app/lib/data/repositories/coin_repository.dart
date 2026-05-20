import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:runvie/data/models/coin_transaction.dart';
import 'package:runvie/services/supabase_service.dart';

/// Earn-rate calculator. Pure / dependency-free so it is trivial to unit
/// test (`coin_earning_test.dart`).
class CoinEarnCalculator {
  const CoinEarnCalculator({
    this.baseCoinPerKm = 10,
    this.minCoinPerKm = 5,
    this.dailyCap = 50,
  });

  /// Coin per km BEFORE level decay — base rate (level 1).
  final int baseCoinPerKm;

  /// Floor after decay — earn never drops below this per km.
  final int minCoinPerKm;

  /// Hard cap regardless of distance. Anti-grind.
  final int dailyCap;

  /// Decay curve: every 10 levels removes 1 coin/km, clamped to
  /// [minCoinPerKm].
  int rateForLevel(int level) {
    final int rate = baseCoinPerKm - (level ~/ 10);
    return max(minCoinPerKm, rate);
  }

  /// Compute coin earned for a run.
  ///
  /// `distanceKm` — total distance of the run.
  /// `level` — user's current level.
  /// `earnedTodaySoFar` — total coin already earned today (from runs only).
  int earningsForRun({
    required double distanceKm,
    required int level,
    required int earnedTodaySoFar,
  }) {
    if (distanceKm <= 0) return 0;
    final int rate = rateForLevel(level);
    final int raw = (distanceKm * rate).floor();
    final int remainingCap = max(0, dailyCap - earnedTodaySoFar);
    return min(raw, remainingCap);
  }
}

/// Coin wallet repository. Wraps Supabase `coin_transactions` /
/// `coin_balances` / `coin_vouchers` tables.
///
/// All mutations are append-only (ledger) — `balanceAfter` is computed and
/// persisted alongside each row so the client can render history without
/// recomputing aggregates.
class CoinRepository {
  CoinRepository({SupabaseClient? client}) : _explicitClient = client;

  final SupabaseClient? _explicitClient;
  SupabaseClient get _client =>
      _explicitClient ?? SupabaseService.instance.client;

  // In-memory ledger — kept in sync with the server. Tests can prime via
  // [debugSeed].
  final List<CoinTransaction> _ledger = <CoinTransaction>[];
  int _balance = 0;
  bool _hydrated = false;

  int get balance => _balance;
  List<CoinTransaction> get ledger => List<CoinTransaction>.unmodifiable(
        _ledger.reversed.toList(growable: false),
      );

  Future<int> getBalance({required String userId}) async {
    if (!_hydrated) {
      await _hydrate(userId: userId);
    }
    return _balance;
  }

  Future<List<CoinTransaction>> history({
    required String userId,
    int limit = 50,
  }) async {
    if (!_hydrated) {
      await _hydrate(userId: userId);
    }
    final List<CoinTransaction> sorted = List<CoinTransaction>.from(_ledger)
      ..sort((CoinTransaction a, CoinTransaction b) =>
          b.createdAt.compareTo(a.createdAt));
    return sorted.take(limit).toList(growable: false);
  }

  Future<void> _hydrate({required String userId}) async {
    try {
      final List<Map<String, dynamic>> rows = await _client
          .from('coin_transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true)
          .then(_castRows);
      _ledger
        ..clear()
        ..addAll(rows.map(CoinTransaction.fromJson));
      _balance = _ledger.isEmpty ? 0 : _ledger.last.balanceAfter;
    } catch (_) {
      // Stay offline-friendly — show 0 until the next sync.
      _balance = 0;
    } finally {
      _hydrated = true;
    }
  }

  /// Append a transaction locally. Sync to Supabase happens in
  /// [_persistRemote] which is best-effort — failure does NOT throw because
  /// the run was already saved; backend reconciliation tolerates retries.
  Future<CoinTransaction> append({
    required String userId,
    required int amount,
    required CoinTxnReason reason,
    String? note,
    String? activityId,
  }) async {
    final int newBalance = _balance + amount;
    final CoinTransaction txn = CoinTransaction(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      amount: amount,
      reason: reason,
      createdAt: DateTime.now(),
      balanceAfter: newBalance,
      note: note,
      activityId: activityId,
    );
    _ledger.add(txn);
    _balance = newBalance;
    _hydrated = true;
    unawaited(_persistRemote(userId: userId, txn: txn));
    return txn;
  }

  Future<void> _persistRemote({
    required String userId,
    required CoinTransaction txn,
  }) async {
    try {
      await _client.from('coin_transactions').insert(<String, dynamic>{
        'user_id': userId,
        ...txn.toJson(),
      });
    } catch (e) {
      // Swallowed by design — the client ledger is the local source of
      // truth until next sync. Log for diagnostics.
      debugPrint('coin sync failed: $e');
    }
  }

  /// Marketplace catalog. Hard-coded fallback shown when the network call
  /// fails — keeps the screen alive on flaky connections.
  Future<List<VoucherOffer>> getVoucherCatalog() async {
    try {
      final List<Map<String, dynamic>> rows = await _client
          .from('coin_vouchers')
          .select()
          .eq('active', true)
          .order('coin_cost', ascending: true)
          .then(_castRows);
      if (rows.isNotEmpty) {
        return rows.map(VoucherOffer.fromJson).toList(growable: false);
      }
    } catch (_) {/* fall through to fallback */}
    return _fallbackCatalog;
  }

  /// Call the `/redeem` Edge Function. Returns the voucher code on success
  /// and atomically deducts the cost from the local ledger.
  Future<RedeemedVoucher> redeem({
    required String userId,
    required VoucherOffer offer,
  }) async {
    if (_balance < offer.coinCost) {
      throw const InsufficientCoinException();
    }
    final dynamic response = await _client.functions.invoke(
      'redeem',
      body: <String, dynamic>{
        'user_id': userId,
        'voucher_id': offer.id,
      },
    );
    // `response` is FunctionResponse in supabase_flutter v2 — access via
    // dynamic to keep this file decoupled from the typed transport.
    // ignore: avoid_dynamic_calls
    final dynamic raw = response.data;
    if (raw is! Map) {
      throw const RedeemFailedException('Phan hoi khong hop le');
    }
    final Map<String, dynamic> data = Map<String, dynamic>.from(raw);
    await append(
      userId: userId,
      amount: -offer.coinCost,
      reason: CoinTxnReason.voucherRedeem,
      note: '${offer.brand} ${offer.title}',
    );
    return RedeemedVoucher.fromJson(data);
  }

  static List<Map<String, dynamic>> _castRows(dynamic raw) {
    if (raw is! List) return const <Map<String, dynamic>>[];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> m) => Map<String, dynamic>.from(m))
        .toList(growable: false);
  }

  /// Test seam.
  @visibleForTesting
  void debugSeed({int? balance, List<CoinTransaction>? ledger}) {
    if (balance != null) _balance = balance;
    if (ledger != null) {
      _ledger
        ..clear()
        ..addAll(ledger);
    }
    _hydrated = true;
  }
}

final List<VoucherOffer> _fallbackCatalog = <VoucherOffer>[
  const VoucherOffer(
    id: 'shopee-50k',
    brand: 'Shopee',
    title: 'Voucher 50.000 d',
    valueVnd: 50000,
    coinCost: 500,
    partnerAppUrl: 'https://shopee.vn',
  ),
  const VoucherOffer(
    id: 'grab-30k',
    brand: 'Grab Food',
    title: 'Voucher 30.000 d',
    valueVnd: 30000,
    coinCost: 300,
    partnerAppUrl: 'https://food.grab.com',
  ),
  const VoucherOffer(
    id: 'lazada-100k',
    brand: 'Lazada',
    title: 'Voucher 100.000 d',
    valueVnd: 100000,
    coinCost: 1000,
    partnerAppUrl: 'https://lazada.vn',
  ),
  const VoucherOffer(
    id: 'highlands-30k',
    brand: 'Highlands',
    title: 'Voucher 30.000 d',
    valueVnd: 30000,
    coinCost: 300,
    partnerAppUrl: 'https://highlandscoffee.com.vn',
  ),
  const VoucherOffer(
    id: 'tch-30k',
    brand: 'The Coffee House',
    title: 'Voucher 30.000 d',
    valueVnd: 30000,
    coinCost: 300,
    partnerAppUrl: 'https://thecoffeehouse.com',
  ),
];

class InsufficientCoinException implements Exception {
  const InsufficientCoinException();
  @override
  String toString() => 'InsufficientCoinException';
}

class RedeemFailedException implements Exception {
  const RedeemFailedException(this.message);
  final String message;
  @override
  String toString() => 'RedeemFailedException($message)';
}

final Provider<CoinEarnCalculator> coinEarnCalculatorProvider =
    Provider<CoinEarnCalculator>((Ref ref) => const CoinEarnCalculator());

final Provider<CoinRepository> coinRepositoryProvider = Provider<CoinRepository>(
  (Ref ref) => CoinRepository(),
);
