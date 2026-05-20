// Integration test: badge award on 5km milestone.
//
// Simulates an activity completion of 5km and asserts that the badge modal
// appears with the expected badge code.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '_helpers/test_app.dart';

abstract class _BadgeService {
  Future<List<String>> evaluate({required double distanceKm});
}

class _MockBadgeService extends Mock implements _BadgeService {}

class _FakePostRun extends StatefulWidget {
  const _FakePostRun({required this.service, required this.distanceKm});
  final _MockBadgeService service;
  final double distanceKm;

  @override
  State<_FakePostRun> createState() => _FakePostRunState();
}

class _FakePostRunState extends State<_FakePostRun> {
  List<String> _newBadges = const [];

  Future<void> _finish() async {
    final earned = await widget.service.evaluate(
      distanceKm: widget.distanceKm,
    );
    setState(() => _newBadges = earned);
    if (earned.isNotEmpty) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          key: const Key('badge_modal'),
          title: const Text('Badge unlocked'),
          content: Text(earned.join(',')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Awesome'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('distance:${widget.distanceKm}'),
          ElevatedButton(
            key: const Key('btn_finish'),
            onPressed: _finish,
            child: const Text('Finish'),
          ),
          for (final b in _newBadges) Text('earned:$b'),
        ],
      ),
    );
  }
}

void main() {
  ensureBinding();

  late _MockBadgeService service;

  setUp(() {
    service = _MockBadgeService();
    when(() => service.evaluate(distanceKm: any(named: 'distanceKm')))
        .thenAnswer((inv) async {
      final d = inv.namedArguments[#distanceKm] as double;
      return d >= 5.0 ? <String>['first_5k'] : <String>[];
    });
  });

  testWidgets('5km run triggers badge modal', (tester) async {
    await bootRunVie(
      tester,
      rootScreen: _FakePostRun(service: service, distanceKm: 5.0),
    );

    await tester.tap(find.byKey(const Key('btn_finish')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('badge_modal')), findsOneWidget);
    expect(find.text('first_5k'), findsOneWidget);

    await tester.tap(find.text('Awesome'));
    await tester.pumpAndSettle();
    expect(find.text('earned:first_5k'), findsOneWidget);
  });
}
