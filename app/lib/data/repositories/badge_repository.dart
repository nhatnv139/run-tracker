import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:runvie/data/models/badge.dart';
import 'package:runvie/services/supabase_service.dart';

/// Repository for badge catalog + user-owned badges.
///
/// `getCatalog()` is cached in-memory for the session — the 62-badge seed
/// rarely changes, so a single round-trip per app launch is enough.
class BadgeRepository {
  BadgeRepository({SupabaseClient? client}) : _explicitClient = client;

  final SupabaseClient? _explicitClient;
  SupabaseClient get _client =>
      _explicitClient ?? SupabaseService.instance.client;

  List<BadgeModel>? _catalogCache;
  final List<UserBadge> _earnedCache = <UserBadge>[];
  bool _earnedHydrated = false;

  /// Load the badge catalog (`badges` table). Throws on transport failure
  /// so the calling provider can surface the error.
  Future<List<BadgeModel>> getCatalog({bool forceRefresh = false}) async {
    if (!forceRefresh && _catalogCache != null) return _catalogCache!;
    final List<Map<String, dynamic>> rows =
        await _client.from('badges').select().then(_castRows);
    final List<BadgeModel> badges =
        rows.map(BadgeModel.fromJson).toList(growable: false);
    _catalogCache = badges;
    return badges;
  }

  Future<List<UserBadge>> getEarned({required String userId}) async {
    if (_earnedHydrated) return List<UserBadge>.unmodifiable(_earnedCache);
    final List<Map<String, dynamic>> rows = await _client
        .from('user_badges')
        .select()
        .eq('user_id', userId)
        .then(_castRows);
    _earnedCache
      ..clear()
      ..addAll(rows.map(UserBadge.fromJson));
    _earnedHydrated = true;
    return List<UserBadge>.unmodifiable(_earnedCache);
  }

  static List<Map<String, dynamic>> _castRows(dynamic raw) {
    if (raw is! List) return const <Map<String, dynamic>>[];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> m) => Map<String, dynamic>.from(m))
        .toList(growable: false);
  }

  /// Call the server-side `award_badges_for_user` RPC after every saved
  /// activity. Backend is the source of truth for award gating (anti-cheat,
  /// idempotency). Returns the list of NEW badges unlocked in this call.
  Future<List<BadgeModel>> awardForActivity({
    required String userId,
    required String activityId,
  }) async {
    final dynamic raw = await _client.rpc<dynamic>(
      'award_badges_for_user',
      params: <String, dynamic>{
        'p_user_id': userId,
        'p_activity_id': activityId,
      },
    );
    if (raw is! List) return const <BadgeModel>[];
    final List<BadgeModel> newOnes = raw
        .whereType<Map<String, dynamic>>()
        .map(BadgeModel.fromJson)
        .toList(growable: false);
    // Update local cache so the gallery reflects immediately.
    for (final BadgeModel b in newOnes) {
      _earnedCache.add(
        UserBadge(
          badgeId: b.id,
          userId: userId,
          earnedAt: DateTime.now(),
          activityId: activityId,
        ),
      );
    }
    _earnedHydrated = true;
    return newOnes;
  }

  /// Test seam — let unit tests prime the cache.
  void debugSeed({List<BadgeModel>? catalog, List<UserBadge>? earned}) {
    if (catalog != null) _catalogCache = List<BadgeModel>.from(catalog);
    if (earned != null) {
      _earnedCache
        ..clear()
        ..addAll(earned);
      _earnedHydrated = true;
    }
  }
}

final Provider<BadgeRepository> badgeRepositoryProvider =
    Provider<BadgeRepository>((Ref ref) => BadgeRepository());
