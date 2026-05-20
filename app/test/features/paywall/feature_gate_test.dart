import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:runvie/features/paywall/presentation/feature_gate.dart';
import 'package:runvie/features/subscription/subscription_providers.dart';
import 'package:runvie/services/iap_service.dart';

Widget _harness({
  required CustomerInfo info,
  required Widget child,
}) {
  final MockIapService mock = MockIapService(initialInfo: info);
  return ProviderScope(
    overrides: <Override>[iapServiceProvider.overrideWithValue(mock)],
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('free user sees lock overlay', (WidgetTester tester) async {
    await tester.pumpWidget(_harness(
      info: const CustomerInfo(
        activeTier: SubscriptionTier.free,
        isInTrial: false,
        trialEndsAt: null,
        expirationDate: null,
        willRenew: false,
      ),
      child: const FeatureGate(
        child: Text('AI Coach Insight'),
      ),
    ));
    // Pump initial refresh future microtasks
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Premium'), findsOneWidget);
    // Child still rendered (we wrap with opacity, not replace)
    expect(find.text('AI Coach Insight'), findsOneWidget);
  });

  testWidgets('premium user sees plain child', (WidgetTester tester) async {
    await tester.pumpWidget(_harness(
      info: CustomerInfo(
        activeTier: SubscriptionTier.pro,
        isInTrial: false,
        trialEndsAt: null,
        expirationDate: DateTime.now().add(const Duration(days: 30)),
        willRenew: true,
      ),
      child: const FeatureGate(
        child: Text('AI Coach Insight'),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Premium'), findsNothing);
    expect(find.text('AI Coach Insight'), findsOneWidget);
  });
}
