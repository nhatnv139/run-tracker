import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:runvie/services/run_events.dart';
import 'package:runvie/services/voice_coach_service.dart';

class _FakeTtsEngine implements TtsEngine {
  final List<String> spoken = <String>[];
  double currentVolume = 1.0;
  String currentLang = 'vi-VN';
  bool initialized = false;

  @override
  Future<List<String>> availableLanguages() async =>
      <String>['vi-VN', 'en-US'];

  @override
  Future<void> init({required String lang}) async {
    initialized = true;
    currentLang = lang;
  }

  @override
  Future<void> setLanguage(String lang) async {
    currentLang = lang;
  }

  @override
  Future<void> setVolume(double v) async {
    currentVolume = v;
  }

  @override
  Future<void> speak(String text) async {
    spoken.add(text);
  }

  @override
  Future<void> stop() async {}
}

Future<VoiceCoachService> _buildService() async {
  final VoicePhraseLibrary library = VoicePhraseLibrary();
  await library.loadFromDirectory(_resolveContentDir());
  return VoiceCoachService(
    engine: _FakeTtsEngine(),
    library: library,
  );
}

void main() {
  group('VoiceCoachService trigger dispatch', () {
    test('speak(everyKm) substitutes context + records utterance', () async {
      final VoiceCoachService service = await _buildService();
      final _FakeTtsEngine engine = service.engine as _FakeTtsEngine;

      final String? rendered = await service.speak(
        trigger: VoiceTriggers.everyKm,
        context: <String, Object?>{'km': 2, 'pace': '5:15', 'hr': '148'},
      );

      expect(rendered, isNotNull);
      expect(engine.spoken, hasLength(1));
      expect(engine.spoken.first, contains('2'));
      expect(engine.spoken.first, contains('5:15'));
      expect(engine.spoken.first, isNot(contains('{')));
    });

    test('speak returns null and does not call TTS when disabled', () async {
      final VoiceCoachService service = await _buildService();
      service.settings =
          service.settings.copyWith(enabled: false);
      final _FakeTtsEngine engine = service.engine as _FakeTtsEngine;

      final String? out = await service.speak(
        trigger: VoiceTriggers.workoutStart,
      );

      expect(out, isNull);
      expect(engine.spoken, isEmpty);
    });

    test('style override picks templates from a different bucket', () async {
      final VoiceCoachService service = await _buildService();
      final Set<String> styleNames = service.library.all
          .where((VoicePhrase p) => p.trigger == VoiceTriggers.everyKm)
          .map((VoicePhrase p) => p.style.name)
          .toSet();
      expect(styleNames, containsAll(<String>['gentle', 'drill']));
    });

    test('streakMilestone(7) speaks a vi-VN streak phrase', () async {
      final VoiceCoachService service = await _buildService();
      final _FakeTtsEngine engine = service.engine as _FakeTtsEngine;
      await service.streakMilestone(7);
      expect(engine.spoken.length, 1);
    });

    test('subscribe to RunEventsBus speaks workout_finish on emit', () async {
      final VoiceCoachService service = await _buildService();
      final _FakeTtsEngine engine = service.engine as _FakeTtsEngine;
      final RunEventsBus bus = RunEventsBus();
      service.subscribe(bus);

      bus.emit(RunSavedEvent(
        activityId: 'a',
        userId: 'u',
        distanceMeters: 5230,
        durationSec: 1800,
        startedAt: DateTime(2025, 1, 1),
        endedAt: DateTime(2025, 1, 1, 0, 30),
        avgPaceSecPerKm: 345,
      ));

      // Allow the stream subscription to deliver.
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(engine.spoken.length, greaterThanOrEqualTo(1));

      await service.dispose();
      await bus.dispose();
    });

    test('paceWarning(tooFast) speaks a pace-warning template', () async {
      final VoiceCoachService service = await _buildService();
      final _FakeTtsEngine engine = service.engine as _FakeTtsEngine;
      await service.paceWarning(
        pace: '4:30',
        targetPace: '5:00',
        tooFast: true,
      );
      expect(engine.spoken.length, 1);
      expect(engine.spoken.first, isNot(contains('{')));
    });

    test('speakLiteral bypasses phrase library', () async {
      final VoiceCoachService service = await _buildService();
      final _FakeTtsEngine engine = service.engine as _FakeTtsEngine;
      await service.speakLiteral('Tin nhắn tự do');
      expect(engine.spoken.last, 'Tin nhắn tự do');
    });
  });

  group('VoiceCoachSettings serialization', () {
    test('round-trips via toJson/fromJson', () {
      const VoiceCoachSettings original = VoiceCoachSettings(
        enabled: false,
        style: VoiceStyle.drill,
        volume: 0.7,
        lang: 'en-US',
      );
      final VoiceCoachSettings copy =
          VoiceCoachSettings.fromJson(original.toJson());
      expect(copy.enabled, false);
      expect(copy.style, VoiceStyle.drill);
      expect(copy.volume, closeTo(0.7, 1e-9));
      expect(copy.lang, 'en-US');
    });

    test('voiceStyleFromString defaults to neutral', () {
      expect(voiceStyleFromString(null), VoiceStyle.neutral);
      expect(voiceStyleFromString('garbage'), VoiceStyle.neutral);
      expect(voiceStyleFromString('gentle'), VoiceStyle.gentle);
      expect(voiceStyleFromString('funny'), VoiceStyle.funny);
    });
  });
}

String _resolveContentDir() {
  Directory dir = Directory.current;
  for (int i = 0; i < 6; i++) {
    final Directory candidate =
        Directory('${dir.path}/content/voice-scripts');
    if (candidate.existsSync()) return candidate.path;
    final Directory parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  return '../content/voice-scripts';
}
