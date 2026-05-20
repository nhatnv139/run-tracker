import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:runvie/services/run_events.dart';

// ---------------------------------------------------------------------------
// Style + settings
// ---------------------------------------------------------------------------

enum VoiceStyle { neutral, gentle, drill, funny }

VoiceStyle voiceStyleFromString(String? raw) {
  switch (raw) {
    case 'gentle':
      return VoiceStyle.gentle;
    case 'drill':
      return VoiceStyle.drill;
    case 'funny':
      return VoiceStyle.funny;
    case 'neutral':
    default:
      return VoiceStyle.neutral;
  }
}

@immutable
class VoiceCoachSettings {
  const VoiceCoachSettings({
    this.enabled = true,
    this.style = VoiceStyle.neutral,
    this.volume = 1.0,
    this.lang = 'vi-VN',
  });

  final bool enabled;
  final VoiceStyle style;
  final double volume;
  final String lang;

  VoiceCoachSettings copyWith({
    bool? enabled,
    VoiceStyle? style,
    double? volume,
    String? lang,
  }) {
    return VoiceCoachSettings(
      enabled: enabled ?? this.enabled,
      style: style ?? this.style,
      volume: volume ?? this.volume,
      lang: lang ?? this.lang,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'enabled': enabled,
        'style': style.name,
        'volume': volume,
        'lang': lang,
      };

  static VoiceCoachSettings fromJson(Map<String, dynamic> j) =>
      VoiceCoachSettings(
        enabled: j['enabled'] as bool? ?? true,
        style: voiceStyleFromString(j['style'] as String?),
        volume: (j['volume'] as num?)?.toDouble() ?? 1.0,
        lang: j['lang'] as String? ?? 'vi-VN',
      );
}

class VoiceCoachSettingsNotifier extends Notifier<VoiceCoachSettings> {
  static const String _prefsKey = 'voice_coach_settings';

  @override
  VoiceCoachSettings build() {
    // Async load — fire and forget; state stays at default until ready.
    Future<void>.microtask(_load);
    return const VoiceCoachSettings();
  }

  Future<void> _load() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        state = VoiceCoachSettings.fromJson(decoded);
      }
    } catch (_) {
      // Ignore — fall back to defaults.
    }
  }

  Future<void> _persist() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(state.toJson()));
    } catch (_) {
      // best-effort.
    }
  }

  Future<void> setEnabled(bool v) async {
    state = state.copyWith(enabled: v);
    await _persist();
  }

  Future<void> setStyle(VoiceStyle s) async {
    state = state.copyWith(style: s);
    await _persist();
  }

  Future<void> setVolume(double v) async {
    state = state.copyWith(volume: v.clamp(0.0, 1.0));
    await _persist();
  }

  Future<void> setLang(String lang) async {
    state = state.copyWith(lang: lang);
    await _persist();
  }
}

final NotifierProvider<VoiceCoachSettingsNotifier, VoiceCoachSettings>
    voiceCoachSettingsProvider =
    NotifierProvider<VoiceCoachSettingsNotifier, VoiceCoachSettings>(
        VoiceCoachSettingsNotifier.new);

// ---------------------------------------------------------------------------
// Phrase library
// ---------------------------------------------------------------------------

@immutable
class VoicePhrase {
  const VoicePhrase({
    required this.id,
    required this.trigger,
    required this.category,
    required this.style,
    required this.lang,
    required this.templates,
  });

  final String id;
  final String trigger;
  final String category;
  final VoiceStyle style;
  final String lang;
  final List<String> templates;
}

/// Loader strategy — abstracted so tests can read from disk directly while
/// production reads from `rootBundle`.
typedef VoiceJsonLoader = Future<String> Function(String name);

Future<String> _rootBundleLoader(String name) async {
  return rootBundle.loadString('assets/voice-scripts/$name');
}

class VoicePhraseLibrary {
  VoicePhraseLibrary({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Index keyed by `"$trigger|$style|$lang"`. Each bucket holds every
  /// matching phrase so we can shuffle templates across phrase ids.
  final Map<String, List<VoicePhrase>> _byKey = <String, List<VoicePhrase>>{};

  /// Fallback index keyed by `"$trigger|$lang"` — used when no exact
  /// style match exists.
  final Map<String, List<VoicePhrase>> _byTriggerLang =
      <String, List<VoicePhrase>>{};

  /// All loaded phrases (read-only) — useful for tests.
  @visibleForTesting
  Iterable<VoicePhrase> get all => _byKey.values.expand(
        (List<VoicePhrase> v) => v,
      );

  /// Default JSON files shipped with the app. Kept here so production
  /// code only needs to call [loadDefaults].
  static const List<String> defaultFiles = <String>[
    'vi-milestone.json',
    'vi-motivation.json',
    'vi-pace-warning.json',
    'vi-start-stop.json',
    'vi-heart-rate-zone.json',
    'vi-weather.json',
    'vi-streak.json',
    'en-milestone.json',
  ];

  Future<void> loadDefaults({VoiceJsonLoader? loader}) async {
    final VoiceJsonLoader effective = loader ?? _rootBundleLoader;
    for (final String name in defaultFiles) {
      try {
        final String raw = await effective(name);
        await loadFromString(raw);
      } catch (_) {
        // Missing asset is non-fatal — skip and continue.
      }
    }
  }

  /// Loads phrases by walking a directory of JSON files (test convenience).
  Future<void> loadFromDirectory(String dirPath) async {
    final Directory dir = Directory(dirPath);
    if (!dir.existsSync()) return;
    final List<FileSystemEntity> files = dir.listSync()
      ..sort((FileSystemEntity a, FileSystemEntity b) =>
          a.path.compareTo(b.path));
    for (final FileSystemEntity entity in files) {
      if (entity is File && entity.path.endsWith('.json')) {
        final String raw = await entity.readAsString();
        await loadFromString(raw);
      }
    }
  }

  Future<void> loadFromString(String raw) async {
    final dynamic decoded = jsonDecode(raw);
    if (decoded is! List) return;
    for (final dynamic item in decoded) {
      if (item is! Map<String, dynamic>) continue;
      final VoicePhrase phrase = VoicePhrase(
        id: item['id'] as String? ?? '',
        trigger: item['trigger'] as String? ?? '',
        category: item['category'] as String? ?? '',
        style: voiceStyleFromString(item['style'] as String?),
        lang: item['lang'] as String? ?? 'vi-VN',
        templates: (item['templates'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic e) => e.toString())
            .toList(growable: false),
      );
      _index(phrase);
    }
  }

  void _index(VoicePhrase phrase) {
    final String key = _key(phrase.trigger, phrase.style, phrase.lang);
    _byKey.putIfAbsent(key, () => <VoicePhrase>[]).add(phrase);
    final String fallback = '${phrase.trigger}|${phrase.lang}';
    _byTriggerLang
        .putIfAbsent(fallback, () => <VoicePhrase>[])
        .add(phrase);
  }

  String _key(String trigger, VoiceStyle style, String lang) =>
      '$trigger|${style.name}|$lang';

  /// Pick a random template that matches the trigger + style + language.
  /// Falls back to (1) same trigger + lang, (2) same trigger any lang.
  /// Returns `null` only if the library is empty for this trigger.
  String? pickTemplate({
    required String trigger,
    required VoiceStyle style,
    String lang = 'vi-VN',
  }) {
    final List<VoicePhrase>? exact = _byKey[_key(trigger, style, lang)];
    if (exact != null && exact.isNotEmpty) {
      return _randomTemplate(exact);
    }
    final List<VoicePhrase>? langMatch = _byTriggerLang['$trigger|$lang'];
    if (langMatch != null && langMatch.isNotEmpty) {
      return _randomTemplate(langMatch);
    }
    final List<VoicePhrase> anyLang = _byKey.values
        .expand((List<VoicePhrase> v) => v)
        .where((VoicePhrase p) => p.trigger == trigger)
        .toList();
    if (anyLang.isEmpty) return null;
    return _randomTemplate(anyLang);
  }

  String _randomTemplate(List<VoicePhrase> phrases) {
    final VoicePhrase chosen = phrases[_random.nextInt(phrases.length)];
    if (chosen.templates.isEmpty) return chosen.id;
    return chosen.templates[_random.nextInt(chosen.templates.length)];
  }

  /// Substitute `{key}` tokens with values from [context]. Unknown keys
  /// are left blank.
  static String substitute(String template, Map<String, Object?> context) {
    return template.replaceAllMapped(
      RegExp(r'\{(\w+)\}'),
      (Match m) {
        final String key = m.group(1)!;
        final Object? value = context[key];
        if (value == null) return '';
        return value.toString();
      },
    );
  }

  /// Convenience: pick + substitute in one call.
  String? render({
    required String trigger,
    required VoiceStyle style,
    String lang = 'vi-VN',
    Map<String, Object?> context = const <String, Object?>{},
  }) {
    final String? template = pickTemplate(
      trigger: trigger,
      style: style,
      lang: lang,
    );
    if (template == null) return null;
    final Map<String, Object?> withDefaults = <String, Object?>{
      ...context,
      if (context['km'] != null && context['km_plus_one'] == null)
        'km_plus_one': (context['km'] as num).toInt() + 1,
    };
    return substitute(template, withDefaults);
  }
}

// ---------------------------------------------------------------------------
// TTS engine abstraction (so tests can mock without flutter_tts plugin)
// ---------------------------------------------------------------------------

abstract class TtsEngine {
  Future<void> init({required String lang});
  Future<void> setVolume(double v);
  Future<void> setLanguage(String lang);
  Future<void> speak(String text);
  Future<void> stop();
  Future<List<String>> availableLanguages();
}

class FlutterTtsEngine implements TtsEngine {
  FlutterTtsEngine([FlutterTts? tts]) : _tts = tts ?? FlutterTts();
  final FlutterTts _tts;

  @override
  Future<void> init({required String lang}) async {
    await _tts.awaitSpeakCompletion(true);
    await _tts.setLanguage(lang);
    // Pre-warm — empty utterance with zero volume gives the engine a
    // chance to load the voice resources without making noise.
    final double prevVolume = 1.0;
    await _tts.setVolume(0);
    try {
      await _tts.speak(' ');
    } catch (_) {
      // ignore platform exceptions during warm-up
    }
    await _tts.setVolume(prevVolume);

    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.ambient,
        <IosTextToSpeechAudioCategoryOptions>[
          IosTextToSpeechAudioCategoryOptions.duckOthers,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );
    }

    // Try to pick a female voice for the requested locale.
    try {
      final dynamic voices = await _tts.getVoices;
      if (voices is List) {
        for (final dynamic v in voices) {
          if (v is Map) {
            final String locale = v['locale']?.toString() ?? '';
            final String name = v['name']?.toString() ?? '';
            final String gender = v['gender']?.toString().toLowerCase() ?? '';
            if (locale == lang && (gender == 'female' ||
                name.toLowerCase().contains('female') ||
                name.toLowerCase().contains('nu'))) {
              await _tts.setVoice(<String, String>{
                'name': name,
                'locale': locale,
              });
              break;
            }
          }
        }
      }
    } catch (_) {
      // Fallback to default voice.
    }
  }

  @override
  Future<void> setVolume(double v) => _tts.setVolume(v);

  @override
  Future<void> setLanguage(String lang) => _tts.setLanguage(lang);

  @override
  Future<void> speak(String text) => _tts.speak(text);

  @override
  Future<void> stop() => _tts.stop();

  @override
  Future<List<String>> availableLanguages() async {
    try {
      final dynamic langs = await _tts.getLanguages;
      if (langs is List) {
        return langs.map((dynamic e) => e.toString()).toList();
      }
    } catch (_) {}
    return <String>[];
  }
}

// ---------------------------------------------------------------------------
// Voice coach service
// ---------------------------------------------------------------------------

/// Trigger keys used by the phrase library + dispatcher. Kept as constants
/// so callers (UI + RunEventsBus subscribers) cannot typo a key.
class VoiceTriggers {
  VoiceTriggers._();

  static const String everyKm = 'every_km';
  static const String workoutStart = 'workout_start';
  static const String workoutPause = 'workout_pause';
  static const String workoutResume = 'workout_resume';
  static const String workoutFinish = 'workout_finish';
  static const String paceTooFast = 'pace_above_target_10pct';
  static const String paceTooSlow = 'pace_below_target_10pct';
  static const String paceOnTarget = 'pace_within_target';
  static const String hrZone4Enter = 'hr_zone_4_entered';
  static const String hrZone5Enter = 'hr_zone_5_entered';
  static const String hrZone5Sustained = 'hr_zone_5_sustained';
  static const String hrZone2Steady = 'hr_zone_2_steady';
  static const String streak3 = 'streak_3_days';
  static const String streak7 = 'streak_7_days';
  static const String streak30 = 'streak_30_days';
  static const String streak100 = 'streak_100_days';
  static const String streak365 = 'streak_365_days';
  static const String streakBroken = 'streak_broken';
  static const String weatherHeat = 'temp_above_32c';
  static const String weatherRain = 'rain_detected';
  static const String weatherCold = 'temp_below_15c';
  static const String weatherAqi = 'aqi_above_150';
}

/// Pure-Dart service. The constructor accepts an injectable TTS engine
/// + phrase library so tests can run with mocks and no native plugin.
class VoiceCoachService {
  VoiceCoachService({
    TtsEngine? engine,
    VoicePhraseLibrary? library,
    AudioSession? audioSession,
  })  : _engine = engine ?? FlutterTtsEngine(),
        _library = library ?? VoicePhraseLibrary(),
        _audioSession = audioSession;

  /// Singleton — used by the rest of the app where DI is not wired.
  static final VoiceCoachService instance = VoiceCoachService();

  final TtsEngine _engine;
  final VoicePhraseLibrary _library;
  AudioSession? _audioSession;

  VoiceCoachSettings _settings = const VoiceCoachSettings();
  StreamSubscription<RunSavedEvent>? _runSubscription;
  bool _initialized = false;

  // Public getters for tests.
  @visibleForTesting
  VoicePhraseLibrary get library => _library;

  @visibleForTesting
  TtsEngine get engine => _engine;

  VoiceCoachSettings get settings => _settings;
  set settings(VoiceCoachSettings v) {
    _settings = v;
    // Apply async — fire and forget.
    Future<void>.microtask(() async {
      await _engine.setLanguage(v.lang);
      await _engine.setVolume(v.volume);
    });
  }

  bool get enabled => _settings.enabled;

  /// One-time init. Safe to call again — subsequent calls are no-ops.
  Future<void> init({
    VoiceJsonLoader? phraseLoader,
    VoiceCoachSettings? initial,
  }) async {
    if (_initialized) return;
    _initialized = true;

    if (initial != null) _settings = initial;

    await _library.loadDefaults(loader: phraseLoader);

    try {
      _audioSession ??= await AudioSession.instance;
      await _audioSession!.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.duckOthers,
        avAudioSessionMode: AVAudioSessionMode.voicePrompt,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions:
            AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.assistanceNavigationGuidance,
        ),
        androidAudioFocusGainType:
            AndroidAudioFocusGainType.gainTransientMayDuck,
        androidWillPauseWhenDucked: false,
      ));
    } catch (_) {
      // audio_session not available in test environment.
    }

    try {
      await _engine.init(lang: _settings.lang);
      await _engine.setVolume(_settings.volume);
    } catch (_) {
      // Plugin may not be available in tests — phrase lookup still works.
    }
  }

  /// Subscribe to the [RunEventsBus] so the service automatically speaks
  /// when a run finishes. The Run-tracking feature is also expected to
  /// emit live `KmMilestone` etc. events on its own controller; those are
  /// dispatched via [speak] directly.
  void subscribe(RunEventsBus bus) {
    _runSubscription?.cancel();
    _runSubscription = bus.stream.listen(_onRunSaved);
  }

  Future<void> dispose() async {
    await _runSubscription?.cancel();
    _runSubscription = null;
  }

  void _onRunSaved(RunSavedEvent e) {
    final int minutes = e.avgPaceSecPerKm ~/ 60;
    final int seconds = (e.avgPaceSecPerKm % 60).toInt();
    speak(
      trigger: VoiceTriggers.workoutFinish,
      context: <String, Object?>{
        'distance': e.distanceKm.toStringAsFixed(2),
        'duration': _formatDuration(e.durationSec),
        'pace': '$minutes:${seconds.toString().padLeft(2, '0')}',
      },
    );
  }

  String _formatDuration(int secs) {
    final int h = secs ~/ 3600;
    final int m = (secs % 3600) ~/ 60;
    final int s = secs % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Lookup + speak. Returns the rendered phrase (for tests) or null if
  /// disabled / no template matched.
  Future<String?> speak({
    required String trigger,
    Map<String, Object?> context = const <String, Object?>{},
    VoiceStyle? styleOverride,
    String? langOverride,
  }) async {
    if (!_settings.enabled) return null;
    final VoiceStyle style = styleOverride ?? _settings.style;
    final String lang = langOverride ?? _settings.lang;
    final String? rendered = _library.render(
      trigger: trigger,
      style: style,
      lang: lang,
      context: context,
    );
    if (rendered == null || rendered.trim().isEmpty) return null;
    try {
      await _activateSession();
      await _engine.speak(rendered);
    } catch (_) {
      // best-effort
    }
    return rendered;
  }

  Future<void> _activateSession() async {
    try {
      await _audioSession?.setActive(true);
    } catch (_) {}
  }

  /// Speak an arbitrary literal — used by chat "speak aloud" actions.
  Future<void> speakLiteral(String text) async {
    if (!_settings.enabled) return;
    try {
      await _activateSession();
      await _engine.speak(text);
    } catch (_) {}
  }

  // ---------- Convenience trigger helpers (back-compat with old API) ----

  Future<void> kilometerCue({
    required int km,
    required Duration elapsed,
    required Duration paceLastKm,
  }) async {
    final String paceStr =
        '${paceLastKm.inMinutes}:${(paceLastKm.inSeconds % 60).toString().padLeft(2, '0')}';
    await speak(
      trigger: VoiceTriggers.everyKm,
      context: <String, Object?>{
        'km': km,
        'pace': paceStr,
        'hr': '',
      },
    );
  }

  Future<void> startCue() =>
      speak(trigger: VoiceTriggers.workoutStart).then((_) {});

  Future<void> pauseCue() =>
      speak(trigger: VoiceTriggers.workoutPause).then((_) {});

  Future<void> resumeCue() =>
      speak(trigger: VoiceTriggers.workoutResume).then((_) {});

  Future<void> finishCue(double distanceKm) => speak(
        trigger: VoiceTriggers.workoutFinish,
        context: <String, Object?>{'distance': distanceKm.toStringAsFixed(2)},
      ).then((_) {});

  Future<void> paceWarning({
    required String pace,
    required String targetPace,
    required bool tooFast,
  }) =>
      speak(
        trigger: tooFast
            ? VoiceTriggers.paceTooFast
            : VoiceTriggers.paceTooSlow,
        context: <String, Object?>{'pace': pace, 'target_pace': targetPace},
      ).then((_) {});

  Future<void> streakMilestone(int days) {
    String trigger;
    if (days >= 365) {
      trigger = VoiceTriggers.streak365;
    } else if (days >= 100) {
      trigger = VoiceTriggers.streak100;
    } else if (days >= 30) {
      trigger = VoiceTriggers.streak30;
    } else if (days >= 7) {
      trigger = VoiceTriggers.streak7;
    } else if (days >= 3) {
      trigger = VoiceTriggers.streak3;
    } else {
      return Future<void>.value();
    }
    return speak(
      trigger: trigger,
      context: <String, Object?>{'days': days},
    ).then((_) {});
  }
}

final Provider<VoiceCoachService> voiceCoachServiceProvider =
    Provider<VoiceCoachService>((Ref ref) {
  final VoiceCoachService service = VoiceCoachService.instance;
  // Wire up to the run events bus so finish-of-run cues fire automatically.
  final RunEventsBus bus = ref.watch(runEventsBusProvider);
  service.subscribe(bus);
  ref.onDispose(service.dispose);
  return service;
});
