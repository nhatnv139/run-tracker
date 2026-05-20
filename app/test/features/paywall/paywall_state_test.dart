import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:runvie/data/repositories/subscription_repository.dart';
import 'package:runvie/features/subscription/subscription_providers.dart';
import 'package:runvie/services/iap_service.dart';

void main() {
  late ProviderContainer container;
  late MockIapService mock;

  setUp(() {
    mock = MockIapService();
    container = ProviderContainer(
      overrides: <Override>[
        iapServiceProvider.overrideWithValue(mock),
      ],
    );
    addTearDown(container.dispose);
  });

  group('initial state', () {
    test('defaults to free', () async {
      // Read once to trigger initial async refresh
      final SubscriptionState s = container.read(subscriptionControllerProvider);
      expect(s.status, SubscriptionStatus.free);
      expect(s.isPremium, false);
    });
  });

  group('trial purchase', () {
    test('moves to trial state with daysLeft', () async {
      final IapOfferings offerings = await mock.getOfferings();
      final IapPackage plus = offerings.packages
          .firstWhere((IapPackage p) => p.tier == SubscriptionTier.plus);
      final bool ok = await container
          .read(subscriptionControllerProvider.notifier)
          .purchase(plus);
      expect(ok, true);
      final SubscriptionState s = container.read(subscriptionControllerProvider);
      expect(s.status, SubscriptionStatus.trial);
      expect(s.trialDaysLeft, greaterThanOrEqualTo(13));
      expect(s.isPremium, true);
    });

    test('non-trial package goes directly into tier', () async {
      mock.debugSetInfo = const CustomerInfo(
        activeTier: SubscriptionTier.pro,
        isInTrial: false,
        trialEndsAt: null,
        expirationDate: null,
        willRenew: true,
      );
      await container
          .read(subscriptionControllerProvider.notifier)
          .refresh();
      final SubscriptionState s = container.read(subscriptionControllerProvider);
      expect(s.status, SubscriptionStatus.pro);
      expect(s.isPremium, true);
    });

    test('cancelled premium maps to cancelled', () async {
      mock.debugSetInfo = CustomerInfo(
        activeTier: SubscriptionTier.pro,
        isInTrial: false,
        trialEndsAt: null,
        expirationDate: DateTime.now().add(const Duration(days: 5)),
        willRenew: false,
      );
      await container
          .read(subscriptionControllerProvider.notifier)
          .refresh();
      final SubscriptionState s = container.read(subscriptionControllerProvider);
      expect(s.status, SubscriptionStatus.cancelled);
    });
  });

  group('snapshot derivation', () {
    test('expired trial degrades to zero days', () {
      final CustomerInfo info = CustomerInfo(
        activeTier: SubscriptionTier.plus,
        isInTrial: true,
        trialEndsAt: DateTime.now().subtract(const Duration(days: 1)),
        expirationDate: DateTime.now().add(const Duration(days: 30)),
        willRenew: true,
      );
      final SubscriptionSnapshot s = SubscriptionSnapshot.fromCustomerInfo(info);
      expect(s.trialDaysLeft, 0);
      expect(s.isInTrial, false);
    });
  });
}
