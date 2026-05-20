import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Subscription tier — mirrors the RevenueCat entitlement identifiers.
enum SubscriptionTier { free, plus, pro, family }

extension SubscriptionTierX on SubscriptionTier {
  String get label {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.plus:
        return 'Plus';
      case SubscriptionTier.pro:
        return 'Pro';
      case SubscriptionTier.family:
        return 'Family';
    }
  }

  /// Price label for the marketing card. Production reads from RevenueCat
  /// offering; we keep static strings here as a fallback / mock value.
  String get priceVnd {
    switch (this) {
      case SubscriptionTier.free:
        return '0 d';
      case SubscriptionTier.plus:
        return '49.000 d / thang';
      case SubscriptionTier.pro:
        return '99.000 d / thang';
      case SubscriptionTier.family:
        return '149.000 d / thang';
    }
  }
}

/// A single purchase option exposed to the paywall UI.
@immutable
class IapPackage {
  const IapPackage({
    required this.identifier,
    required this.tier,
    required this.priceString,
    required this.trialDays,
    required this.billingPeriodMonths,
  });

  final String identifier;
  final SubscriptionTier tier;
  final String priceString;
  final int trialDays;
  final int billingPeriodMonths;
}

@immutable
class IapOfferings {
  const IapOfferings({required this.packages});
  final List<IapPackage> packages;
}

@immutable
class CustomerInfo {
  const CustomerInfo({
    required this.activeTier,
    required this.isInTrial,
    required this.trialEndsAt,
    required this.expirationDate,
    required this.willRenew,
  });

  final SubscriptionTier activeTier;
  final bool isInTrial;
  final DateTime? trialEndsAt;
  final DateTime? expirationDate;
  final bool willRenew;

  bool get isPremium => activeTier != SubscriptionTier.free;
}

class PurchaseException implements Exception {
  PurchaseException(this.message, {this.userCancelled = false});
  final String message;
  final bool userCancelled;
  @override
  String toString() => 'PurchaseException($message)';
}

/// Abstract IAP facade — production binds to RevenueCat (`purchases_flutter`),
/// dev/test binds to [MockIapService].
abstract class IapService {
  Future<void> configure({required String userId});
  Future<IapOfferings> getOfferings();
  Future<CustomerInfo> purchasePackage(IapPackage package);
  Future<CustomerInfo> restorePurchases();
  Future<CustomerInfo> getCustomerInfo();
  Future<bool> isPremium();
}

/// In-memory mock — used until the production RevenueCat keys land. Honors
/// the same contract so we can swap implementations without changing UI.
class MockIapService implements IapService {
  MockIapService({CustomerInfo? initialInfo})
      : _info = initialInfo ??
            const CustomerInfo(
              activeTier: SubscriptionTier.free,
              isInTrial: false,
              trialEndsAt: null,
              expirationDate: null,
              willRenew: false,
            );

  CustomerInfo _info;

  /// Test seam — flip the mock to a specific state.
  // ignore: avoid_setters_without_getters
  set debugSetInfo(CustomerInfo info) => _info = info;

  @override
  Future<void> configure({required String userId}) async {
    // no-op for mock
  }

  @override
  Future<IapOfferings> getOfferings() async {
    return const IapOfferings(
      packages: <IapPackage>[
        IapPackage(
          identifier: 'runvie_plus_monthly',
          tier: SubscriptionTier.plus,
          priceString: '49.000 d / thang',
          trialDays: 14,
          billingPeriodMonths: 1,
        ),
        IapPackage(
          identifier: 'runvie_pro_monthly',
          tier: SubscriptionTier.pro,
          priceString: '99.000 d / thang',
          trialDays: 14,
          billingPeriodMonths: 1,
        ),
        IapPackage(
          identifier: 'runvie_pro_yearly',
          tier: SubscriptionTier.pro,
          priceString: '699.000 d / nam',
          trialDays: 14,
          billingPeriodMonths: 12,
        ),
        IapPackage(
          identifier: 'runvie_family_yearly',
          tier: SubscriptionTier.family,
          priceString: '999.000 d / nam',
          trialDays: 14,
          billingPeriodMonths: 12,
        ),
      ],
    );
  }

  @override
  Future<CustomerInfo> purchasePackage(IapPackage package) async {
    final DateTime now = DateTime.now();
    final DateTime trialEnd = now.add(Duration(days: package.trialDays));
    final DateTime expiration =
        now.add(Duration(days: 30 * package.billingPeriodMonths));
    _info = CustomerInfo(
      activeTier: package.tier,
      isInTrial: package.trialDays > 0,
      trialEndsAt: package.trialDays > 0 ? trialEnd : null,
      expirationDate: expiration,
      willRenew: true,
    );
    return _info;
  }

  @override
  Future<CustomerInfo> restorePurchases() async => _info;

  @override
  Future<CustomerInfo> getCustomerInfo() async => _info;

  @override
  Future<bool> isPremium() async => _info.isPremium;
}

final Provider<IapService> iapServiceProvider = Provider<IapService>((Ref ref) {
  // Production swap: return RevenueCatIapService() here when keys are
  // configured. The mock is intentionally always-on for dev so the paywall
  // is testable without an account.
  return MockIapService();
});
