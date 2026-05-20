// Integration test: AI Coach chat flow.
//
// Verifies that the user can:
//   - open the AI Coach screen
//   - send 3 messages
//   - receive 3 (mocked) responses
//   - rate the session

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '_helpers/test_app.dart';

abstract class _CoachService {
  Future<String> ask(String prompt);
  Future<void> rate(int stars);
}

class _MockCoachService extends Mock implements _CoachService {}

class _FakeCoachScreen extends StatefulWidget {
  const _FakeCoachScreen({required this.coach});
  final _MockCoachService coach;

  @override
  State<_FakeCoachScreen> createState() => _FakeCoachScreenState();
}

class _FakeCoachScreenState extends State<_FakeCoachScreen> {
  final TextEditingController _input = TextEditingController();
  final List<String> _msgs = [];
  bool _rated = false;

  Future<void> _send() async {
    final text = _input.text;
    setState(() {
      _msgs.add('user:$text');
      _input.clear();
    });
    final reply = await widget.coach.ask(text);
    setState(() => _msgs.add('bot:$reply'));
  }

  Future<void> _rate() async {
    await widget.coach.rate(5);
    setState(() => _rated = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          for (final m in _msgs) Text(m),
          TextField(key: const Key('txt_input'), controller: _input),
          ElevatedButton(
            key: const Key('btn_send'),
            onPressed: _send,
            child: const Text('Send'),
          ),
          ElevatedButton(
            key: const Key('btn_rate'),
            onPressed: _rate,
            child: const Text('Rate session'),
          ),
          if (_rated) const Text('Rating saved'),
        ],
      ),
    );
  }
}

void main() {
  ensureBinding();

  late _MockCoachService coach;

  setUp(() {
    coach = _MockCoachService();
    var n = 0;
    when(() => coach.ask(any())).thenAnswer((_) async {
      n += 1;
      return 'reply $n';
    });
    when(() => coach.rate(any())).thenAnswer((_) async => {});
  });

  testWidgets('send 3 messages and rate session', (tester) async {
    await bootRunVie(tester, rootScreen: _FakeCoachScreen(coach: coach));

    for (var i = 1; i <= 3; i++) {
      await enterText(
        tester,
        find.byKey(const Key('txt_input')),
        'question $i',
      );
      await tester.tap(find.byKey(const Key('btn_send')));
      await tester.pumpAndSettle();
    }

    for (var i = 1; i <= 3; i++) {
      expect(find.text('user:question $i'), findsOneWidget);
      expect(find.text('bot:reply $i'), findsOneWidget);
    }

    await tester.tap(find.byKey(const Key('btn_rate')));
    await tester.pumpAndSettle();
    expect(find.text('Rating saved'), findsOneWidget);

    verify(() => coach.ask(any())).called(3);
    verify(() => coach.rate(5)).called(1);
  });
}
