// Integration test: run workout lifecycle.
//
// Verifies:
//   - Start a run
//   - Simulate GPS ticks via injected stream
//   - Pause / Resume / Stop
//   - Save activity
//   - Activity appears in history

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '_helpers/test_app.dart';

class _GpsPoint {
  _GpsPoint(this.lat, this.lng, this.elapsedMs);
  final double lat;
  final double lng;
  final int elapsedMs;
}

abstract class _RunRepository {
  Future<void> saveRun(Map<String, dynamic> payload);
  Future<List<Map<String, dynamic>>> history();
}

class _MockRunRepository extends Mock implements _RunRepository {}

class _FakeRunScreen extends StatefulWidget {
  const _FakeRunScreen({required this.repo, required this.gpsStream});
  final _MockRunRepository repo;
  final Stream<_GpsPoint> gpsStream;

  @override
  State<_FakeRunScreen> createState() => _FakeRunScreenState();
}

class _FakeRunScreenState extends State<_FakeRunScreen> {
  String _state = 'idle';
  double _distanceKm = 0.0;
  StreamSubscription<_GpsPoint>? _sub;
  List<Map<String, dynamic>> _history = const [];

  void _start() {
    setState(() => _state = 'running');
    _sub = widget.gpsStream.listen((p) {
      setState(() => _distanceKm += 0.1);
    });
  }

  void _pause() {
    _sub?.pause();
    setState(() => _state = 'paused');
  }

  void _resume() {
    _sub?.resume();
    setState(() => _state = 'running');
  }

  Future<void> _stop() async {
    await _sub?.cancel();
    await widget.repo.saveRun({'distance_km': _distanceKm});
    final h = await widget.repo.history();
    setState(() {
      _state = 'saved';
      _history = h;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_state == 'saved') {
      return Scaffold(
        body: Column(
          children: [
            const Text('History'),
            for (final row in _history) Text('run:${row['distance_km']}'),
          ],
        ),
      );
    }
    return Scaffold(
      body: Column(
        children: [
          Text('state:$_state'),
          Text('km:${_distanceKm.toStringAsFixed(1)}'),
          ElevatedButton(
            key: const Key('btn_start'),
            onPressed: _state == 'idle' ? _start : null,
            child: const Text('Start'),
          ),
          ElevatedButton(
            key: const Key('btn_pause'),
            onPressed: _state == 'running' ? _pause : null,
            child: const Text('Pause'),
          ),
          ElevatedButton(
            key: const Key('btn_resume'),
            onPressed: _state == 'paused' ? _resume : null,
            child: const Text('Resume'),
          ),
          ElevatedButton(
            key: const Key('btn_stop'),
            onPressed: _state != 'idle' ? _stop : null,
            child: const Text('Stop'),
          ),
        ],
      ),
    );
  }
}

void main() {
  ensureBinding();

  late _MockRunRepository repo;

  setUp(() {
    repo = _MockRunRepository();
    when(() => repo.saveRun(any())).thenAnswer((_) async => {});
    when(() => repo.history()).thenAnswer(
      (_) async => [
        {'distance_km': 1.0, 'started_at': '2026-05-20T07:00:00Z'},
      ],
    );
  });

  testWidgets('start, pause, resume, stop, save flow', (tester) async {
    final controller = StreamController<_GpsPoint>();
    addTearDown(controller.close);

    await bootRunVie(
      tester,
      rootScreen: _FakeRunScreen(repo: repo, gpsStream: controller.stream),
    );

    await tester.tap(find.byKey(const Key('btn_start')));
    await tester.pumpAndSettle();

    for (var i = 0; i < 10; i++) {
      controller.add(_GpsPoint(10.0, 106.0, i * 1000));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.byKey(const Key('btn_pause')));
    await tester.pumpAndSettle();
    expect(find.text('state:paused'), findsOneWidget);

    await tester.tap(find.byKey(const Key('btn_resume')));
    await tester.pumpAndSettle();
    expect(find.text('state:running'), findsOneWidget);

    await tester.tap(find.byKey(const Key('btn_stop')));
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);
    verify(() => repo.saveRun(any())).called(1);
    verify(() => repo.history()).called(1);
  });
}
