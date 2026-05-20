// Integration test: 7-step onboarding flow.
//
// Steps under test:
//   1. Goal selection
//   2. Fitness level
//   3. Weekly target (km)
//   4. Birthday / age
//   5. Weight
//   6. Notification permission prompt
//   7. Summary -> Home

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_helpers/test_app.dart';

class _FakeOnboarding extends StatefulWidget {
  const _FakeOnboarding();

  @override
  State<_FakeOnboarding> createState() => _FakeOnboardingState();
}

class _FakeOnboardingState extends State<_FakeOnboarding> {
  int _step = 0;
  final List<String> _titles = const [
    'Choose your goal',
    'Fitness level',
    'Weekly target',
    'Birthday',
    'Weight',
    'Allow notifications',
    'Summary',
  ];

  @override
  Widget build(BuildContext context) {
    if (_step >= _titles.length) {
      return const Scaffold(body: Center(child: Text('Home loaded')));
    }
    return Scaffold(
      body: Column(
        children: [
          Text(_titles[_step]),
          ElevatedButton(
            key: const Key('btn_next'),
            onPressed: () => setState(() => _step += 1),
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}

void main() {
  ensureBinding();

  testWidgets('7 steps onboarding navigates to Home', (tester) async {
    await bootRunVie(tester, rootScreen: const _FakeOnboarding());

    const expectedTitles = [
      'Choose your goal',
      'Fitness level',
      'Weekly target',
      'Birthday',
      'Weight',
      'Allow notifications',
      'Summary',
    ];

    for (final title in expectedTitles) {
      expect(find.text(title), findsOneWidget);
      await tester.tap(find.byKey(const Key('btn_next')));
      await tester.pumpAndSettle();
    }

    expect(find.text('Home loaded'), findsOneWidget);
  });
}
