// Integration test: step counter ring + streak.
//
// Mocks the pedometer stream and verifies:
//   - Daily goal ring updates as steps arrive
//   - Streak counter increments when goal is met

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '_helpers/test_app.dart';

abstract class _StreakService {
  Future<int> bumpStreakIfGoalMet({required int steps, required int goal});
}

class _MockStreakService extends Mock implements _StreakService {}

class _FakeStepsRing extends StatefulWidget {
  const _FakeStepsRing({
    required this.stream,
    required this.streak,
    this.goal = 8000,
  });

  final Stream<int> stream;
  final _MockStreakService streak;
  final int goal;

  @override
  State<_FakeStepsRing> createState() => _FakeStepsRingState();
}

class _FakeStepsRingState extends State<_FakeStepsRing> {
  int _steps = 0;
  int _streakDays = 0;
  StreamSubscription<int>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = widget.stream.listen((s) async {
      setState(() => _steps = s);
      if (s >= widget.goal) {
        final days = await widget.streak.bumpStreakIfGoalMet(
          steps: s,
          goal: widget.goal,
        );
        setState(() => _streakDays = days);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_steps / widget.goal).clamp(0.0, 1.0);
    return Scaffold(
      body: Column(
        children: [
          Text('steps:$_steps'),
          Text('progress:${(progress * 100).toStringAsFixed(0)}'),
          Text('streak:$_streakDays'),
        ],
      ),
    );
  }
}

void main() {
  ensureBinding();

  late _MockStreakService streak;

  setUp(() {
    streak = _MockStreakService();
    when(() => streak.bumpStreakIfGoalMet(
          steps: any(named: 'steps'),
          goal: any(named: 'goal'),
        )).thenAnswer((_) async => 3);
  });

  testWidgets('pedometer ticks update ring and streak', (tester) async {
    final controller = StreamController<int>();
    addTearDown(controller.close);

    await bootRunVie(
      tester,
      rootScreen: _FakeStepsRing(stream: controller.stream, streak: streak),
    );

    controller.add(2000);
    await tester.pumpAndSettle();
    expect(find.text('steps:2000'), findsOneWidget);
    expect(find.text('progress:25'), findsOneWidget);

    controller.add(8000);
    await tester.pumpAndSettle();
    expect(find.text('steps:8000'), findsOneWidget);
    expect(find.text('progress:100'), findsOneWidget);
    expect(find.text('streak:3'), findsOneWidget);

    verify(() => streak.bumpStreakIfGoalMet(steps: 8000, goal: 8000)).called(1);
  });
}
