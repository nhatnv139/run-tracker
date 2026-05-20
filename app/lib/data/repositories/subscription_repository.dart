import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runvie/services/iap_service.dart';

/// Snapshot of the user's current subscription, projected from RevenueCat
/// CustomerInfo into something the UI can switch on directly.
@immutable
class SubscriptionSnapshot {
  const SubscriptionSnapshot({
    required this.tier,
    required this.isInTrial,
    required this.trialDaysLeft,
    required this.willRenew,
    required this.expiresAt,
  });

  const SubscriptionSnapshot.free()
      : tier = SubscriptionTier.free,
        isInTrial = false,
        trialDaysLeft = 0,
        willRenew = false,
        expiresAt = null;

  final SubscriptionTier tier;
  final bool isInTrial;

  /// Days remaining in the free trial — only meaningful when [isInTrial] is
  /// true.
  final int trialDaysLeft;
  final bool willRenew;
  final DateTime? expiresAt;

  bool get isPremium => tier != SubscriptionTier.free;
  bool get isCancelled => isPremium && !willRenew;

  SubscriptionSnapshot copyWith({
    SubscriptionTier? tier,
    bool? isInTrial,
    int? trialDaysLeft,
    bool? willRenew,
    DateTime? expiresAt,
  }) {
    return SubscriptionSnapshot(
      tier: tier ?? this.tier,
      isInTrial: isInTrial ?? this.isInTrial,
      trialDaysLeft: trialDaysLeft ?? this.trialDaysLeft,
      willRenew: willRenew ?? this.willRenew,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  factory SubscriptionSnapshot.fromCustomerInfo(CustomerInfo info) {
    final DateTime now = DateTime.now();
    int trialDaysLeft = 0;
    if (info.isInTrial && info.trialEndsAt != null) {
      final Duration delta = info.trialEndsAt!.difference(now);
      trialDaysLeft = delta.inHours > 0 ? (delta.inHours / 24).ceil() : 0;
    }
    return SubscriptionSnapshot(
      tier: info.activeTier,
      isInTrial: info.isInTrial && trialDaysLeft > 0,
      trialDaysLeft: trialDaysLeft,
      willRenew: info.willRenew,
      expiresAt: info.expirationDate,
    );
  }
}

/// Repository — bridges [IapService] and the rest of the app. Centralises
/// trial / downgrade logic so feature code stays simple.
class SubscriptionRepository {
  SubscriptionRepository({required IapService iap}) : _iap = iap;

  final IapService _iap;

  Future<SubscriptionSnapshot> current() async {
    final CustomerInfo info = await _iap.getCustomerInfo();
    return SubscriptionSnapshot.fromCustomerInfo(info);
  }

  Future<List<IapPackage>> offerings() async {
    return (await _iap.getOfferings()).packages;
  }

  Future<SubscriptionSnapshot> purchase(IapPackage package) async {
    final CustomerInfo info = await _iap.purchasePackage(package);
    return SubscriptionSnapshot.fromCustomerInfo(info);
  }

  Future<SubscriptionSnapshot> restore() async {
    final CustomerInfo info = await _iap.restorePurchases();
    return SubscriptionSnapshot.fromCustomerInfo(info);
  }
}

final Provider<SubscriptionRepository> subscriptionRepositoryProvider =
    Provider<SubscriptionRepository>((Ref ref) {
  return SubscriptionRepository(iap: ref.watch(iapServiceProvider));
});
