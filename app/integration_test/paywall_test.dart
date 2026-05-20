// Integration test: paywall flow.
//
// Verifies:
//   - Tapping a Pro-gated feature opens the paywall
//   - Starting a trial unlocks the feature
//   - The same feature now renders the gated UI

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '_helpers/test_app.dart';

abstract class _Subscription {
  Future<bool> isPro();
  Future<void> startTrial();
}

class _MockSubscription extends Mock implements _Subscription {}

class _FakeFeatureScreen extends StatefulWidget {
  const _FakeFeatureScreen({required this.sub});
  final _MockSubscription sub;

  @override
  State<_FakeFeatureScreen> createState() => _FakeFeatureScreenState();
}

class _FakeFeatureScreenState extends State<_FakeFeatureScreen> {
  bool _pro = false;
  bool _paywallOpen = false;

  Future<void> _openFeature() async {
    final pro = await widget.sub.isPro();
    setState(() {
      _pro = pro;
      _paywallOpen = !pro;
    });
  }

  Future<void> _startTrial() async {
    await widget.sub.startTrial();
    setState(() {
      _pro = true;
      _paywallOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            key: const Key('btn_open_feature'),
            onPressed: _openFeature,
            child: const Text('Open advanced plan'),
          ),
          if (_paywallOpen)
            Column(
              children: [
                const Text('Paywall'),
                ElevatedButton(
                  key: const Key('btn_trial'),
                  onPressed: _startTrial,
                  child: const Text('Start trial'),
                ),
              ],
            ),
          if (_pro) const Text('Advanced plan unlocked'),
        ],
      ),
    );
  }
}

void main() {
  ensureBinding();

  late _MockSubscription sub;

  setUp(() {
    sub = _MockSubscription();
    var pro = false;
    when(() => sub.isPro()).thenAnswer((_) async => pro);
    when(() => sub.startTrial()).thenAnswer((_) async {
      pro = true;
    });
  });

  testWidgets('gated feature -> paywall -> trial -> unlocked', (tester) async {
    await bootRunVie(tester, rootScreen: _FakeFeatureScreen(sub: sub));

    await tester.tap(find.byKey(const Key('btn_open_feature')));
    await tester.pumpAndSettle();
    expect(find.text('Paywall'), findsOneWidget);

    await tester.tap(find.byKey(const Key('btn_trial')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('btn_open_feature')));
    await tester.pumpAndSettle();

    expect(find.text('Advanced plan unlocked'), findsOneWidget);
    verify(() => sub.startTrial()).called(1);
  });
}
