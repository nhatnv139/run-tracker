import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runvie/shared/extensions/duration_extensions.dart';

enum RunStatus { idle, running, paused, finished }

@immutable
class RunSessionState {
  const RunSessionState({
    this.status = RunStatus.idle,
    this.distanceMeters = 0,
    this.elapsed = Duration.zero,
    this.calories = 0,
    this.currentPace = Duration.zero,
  });

  final RunStatus status;
  final double distanceMeters;
  final Duration elapsed;
  final double calories;
  final Duration currentPace;

  double get distanceKm => distanceMeters / 1000.0;
  String get elapsedFormatted => elapsed.clockFormat;
  String get paceFormatted =>
      currentPace == Duration.zero ? "--'--\"" : currentPace.paceFormat;

  RunSessionState copyWith({
    RunStatus? status,
    double? distanceMeters,
    Duration? elapsed,
    double? calories,
    Duration? currentPace,
  }) {
    return RunSessionState(
      status: status ?? this.status,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      elapsed: elapsed ?? this.elapsed,
      calories: calories ?? this.calories,
      currentPace: currentPace ?? this.currentPace,
    );
  }
}

class RunSessionController extends Notifier<RunSessionState> {
  Timer? _tick;

  @override
  RunSessionState build() {
    ref.onDispose(() => _tick?.cancel());
    return const RunSessionState();
  }

  void start() {
    state = state.copyWith(status: RunStatus.running);
    _startTicker();
  }

  void pause() {
    _tick?.cancel();
    state = state.copyWith(status: RunStatus.paused);
  }

  void resume() {
    state = state.copyWith(status: RunStatus.running);
    _startTicker();
  }

  void stop() {
    _tick?.cancel();
    state = state.copyWith(status: RunStatus.finished);
  }

  void _startTicker() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      // TODO: replace with actual location stream / distance accumulator
      state = state.copyWith(
        elapsed: state.elapsed + const Duration(seconds: 1),
      );
    });
  }
}

final NotifierProvider<RunSessionController, RunSessionState>
    runSessionProvider = NotifierProvider<RunSessionController, RunSessionState>(
  RunSessionController.new,
);
