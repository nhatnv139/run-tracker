# Flutter Instrumentation Guide

Stack: `posthog_flutter ^4.x`, `sentry_flutter ^8.x`, `connectivity_plus`, `flutter_secure_storage`. Dart 3.5+, Flutter 3.24+.

The goal is a **typed, lint-friendly, offline-safe** analytics layer. Engineers never call PostHog directly; they call `AnalyticsService` typed methods. Typos fail at compile time.

---

## 1. Setup — `main.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:runvie/core/analytics/analytics_service.dart';
import 'package:runvie/core/analytics/route_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Posthog().setup(
    PostHogConfig('PHC_xxx')
      ..host = 'https://ph.runvie.app'
      ..captureApplicationLifecycleEvents = false  // we do it explicitly
      ..captureScreenViews = false
      ..flushAt = 20
      ..flushInterval = 30
      ..personProfiles = 'identified_only'
      ..sessionReplayConfig.maskAllInputs = true
      ..sessionReplayConfig.maskAllImages = true,
  );

  await SentryFlutter.init(
    (o) {
      o.dsn = 'https://xxx@sentry.runvie.app/2';
      o.tracesSampleRate = 0.2;
      o.profilesSampleRate = 0.1;
      o.attachScreenshot = false;        // privacy
      o.attachViewHierarchy = false;
      o.sendDefaultPii = false;
      o.beforeSend = scrubPiiBeforeSend; // strip emails / tokens
      o.beforeBreadcrumb = analyticsBreadcrumbBridge;
    },
    appRunner: () => runApp(const RunVieApp()),
  );

  AnalyticsService.instance.bootstrap();  // attaches lifecycle observer + flush worker
}
```

---

## 2. The wrapper — `analytics_service.dart`

```dart
class AnalyticsService {
  AnalyticsService._();
  static final instance = AnalyticsService._();

  final _queue = OfflineEventQueue();   // sqflite-backed
  late final RouteObserver<PageRoute> routeObserver;

  void bootstrap() {
    routeObserver = AnalyticsRouteObserver(this);
    _attachLifecycle();
    _queue.startFlushWorker();
  }

  /// Identify the user. Idempotent.
  Future<void> identify({
    required String userId,
    required UserProperties props,
  }) async {
    await Posthog().identify(
      userId: userId,
      userProperties: props.toJson(),
      userPropertiesSetOnce: props.toJsonSetOnce(),
    );
    Sentry.configureScope((s) => s.setUser(SentryUser(id: userId)));
  }

  Future<void> reset() async {
    await Posthog().reset();
    Sentry.configureScope((s) => s.setUser(null));
  }

  // ===== Typed event API — exhaustive in code, one method per event =====

  Future<void> appOpened({
    required LaunchType launchType,
    required int coldStartMs,
    int? fromBackgroundSeconds,
    required ReferrerSource referrerSource,
    String? lastScreen,
  }) =>
      _capture('app_opened', {
        'launch_type': launchType.name,
        'cold_start_ms': coldStartMs,
        'from_background_seconds': fromBackgroundSeconds,
        'referrer_source': referrerSource.name,
        'last_screen': lastScreen,
      });

  Future<void> activityStarted({
    required ActivityType activityType,
    required ActivitySource source,
    required bool autoPauseEnabled,
    required bool voiceCoachEnabled,
    AudioProvider audioProvider = AudioProvider.none,
    required double gpsAccuracyM,
    double? weatherTempC,
  }) =>
      _capture('activity_started', {
        'activity_type': activityType.name,
        'source': source.name,
        'auto_pause_enabled': autoPauseEnabled,
        'voice_coach_enabled': voiceCoachEnabled,
        'audio_provider': audioProvider.name,
        'gps_accuracy_m': gpsAccuracyM,
        'weather_temp_c': weatherTempC,
      });

  // ... 90 more typed methods, one per spec event ...

  // ===== Private capture =====

  Future<void> _capture(String name, Map<String, Object?> props) async {
    // 1. Strip nulls (PostHog stores nulls as keys; we don't want that).
    final cleaned = <String, Object>{};
    props.forEach((k, v) {
      if (v != null) cleaned[k] = v;
    });

    // 2. Lint-time guard against PII keys (also enforced by custom_lint).
    assert(() {
      for (final k in cleaned.keys) {
        if (_piiBannedKeys.contains(k)) {
          throw StateError('PII key forbidden: $k');
        }
      }
      return true;
    }());

    // 3. If offline, queue for later.
    if (!await NetworkStatus.online) {
      await _queue.enqueue(name, cleaned);
      return;
    }

    // 4. Send via PostHog.
    await Posthog().capture(eventName: name, properties: cleaned);

    // 5. Drop a Sentry breadcrumb for cross-tool debugging.
    await Sentry.addBreadcrumb(Breadcrumb(
      category: 'analytics',
      type: 'info',
      message: name,
      data: cleaned,
      level: SentryLevel.info,
    ));
  }

  static const _piiBannedKeys = {
    'email', 'phone', 'name', 'first_name', 'last_name',
    'birthday', 'address', 'gps_home', 'raw_token',
  };
}
```

---

## 3. Strongly-typed enums (excerpt)

```dart
enum LaunchType { cold, warm, hot }
enum ReferrerSource { direct, push, deeplink, widget, siri, shortcut }
enum ActivityType { run, walk, cycle, treadmill_run, indoor_walk }
enum ActivitySource { gps, treadmill, indoor_pod, watch }
enum AudioProvider { spotify, apple_music, youtube_music, none }
enum AiIntent { plan_advice, recovery, nutrition, gear, injury, small_talk, other }
enum PaywallPlacement { onboarding, post_workout, feature_gate, milestone, settings, push }
// ... matches the spec one-to-one ...
```

These compile-time enums catch every typo. Code generation via `build_runner` reads `events-spec.md` (parsed) and emits the enums + the typed method signatures — single source of truth.

---

## 4. Automatic screen tracking — `RouteObserver`

```dart
class AnalyticsRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  AnalyticsRouteObserver(this._analytics);
  final AnalyticsService _analytics;

  static const _screenWhitelist = <String>{
    'home_feed', 'activity_record', 'activity_summary',
    'training_plan_overview', 'paywall', 'ai_chat',
    'profile', 'leaderboard', 'marketplace', 'settings',
  };

  static const _screenBlocklist = <String>{
    'healthkit_authorization', 'injury_log_detail',
    'weight_history', 'profile_personal_detail',
    'ai_chat_message_detail',
  };

  void _onScreen(Route<dynamic>? r) {
    final name = r?.settings.name;
    if (name == null) return;
    if (_screenBlocklist.contains(name)) return;          // never tracked
    if (!_screenWhitelist.contains(name)) return;         // require whitelist
    _analytics._capture('screen_viewed', {'screen_name': name});
  }

  @override
  void didPush(Route route, Route? previous) {
    super.didPush(route, previous);
    _onScreen(route);
  }
  @override
  void didPop(Route route, Route? previous) {
    super.didPop(route, previous);
    _onScreen(previous);
  }
  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _onScreen(newRoute);
  }
}
```

Attach in `MaterialApp`:

```dart
MaterialApp.router(
  routerConfig: appRouter,
  observers: [AnalyticsService.instance.routeObserver],
);
```

---

## 5. Offline queue — `offline_event_queue.dart`

```dart
class OfflineEventQueue {
  static const _maxRows = 5_000;
  late final Database _db;
  Timer? _worker;

  Future<void> enqueue(String name, Map<String, Object> props) async {
    await _db.insert('events', {
      'name': name,
      'properties': jsonEncode(props),
      'queued_at': DateTime.now().toIso8601String(),
    });
    await _trim();
  }

  void startFlushWorker() {
    _worker = Timer.periodic(const Duration(seconds: 30), (_) => _flush());
    NetworkStatus.onChange.listen((online) {
      if (online) _flush();
    });
  }

  Future<void> _flush() async {
    if (!await NetworkStatus.online) return;
    final batch = await _db.query('events', limit: 50, orderBy: 'id ASC');
    if (batch.isEmpty) return;
    for (final row in batch) {
      try {
        await Posthog().capture(
          eventName: row['name'] as String,
          properties: jsonDecode(row['properties'] as String),
        );
        await _db.delete('events', where: 'id = ?', whereArgs: [row['id']]);
      } catch (_) {
        // exponential backoff; stop this run
        return;
      }
    }
  }

  Future<void> _trim() async {
    final count = Sqflite.firstIntValue(
        await _db.rawQuery('SELECT COUNT(*) FROM events')) ?? 0;
    if (count > _maxRows) {
      await _db.rawDelete(
        'DELETE FROM events WHERE id IN (SELECT id FROM events ORDER BY id ASC LIMIT ?)',
        [count - _maxRows],
      );
    }
  }
}
```

---

## 6. Sentry breadcrumb bridge

Every PostHog event also becomes a Sentry breadcrumb, so when a crash occurs we see the last 20 user actions. The reverse — Sentry crash → PostHog `app_crashed` event — happens on next launch via Sentry's `lastRun`:

```dart
Future<void> reportLastCrashIfAny() async {
  final lastRun = await SentryFlutter.lastRun();
  if (lastRun?.crashed == true) {
    await AnalyticsService.instance._capture('app_crashed', {
      'sentry_event_id': lastRun!.eventId ?? 'unknown',
      'crash_type': lastRun.crashType ?? 'dart',
    });
  }
}
```

---

## 7. Examples for the 10 most important events

```dart
// 1. App opened (cold start with deferred deeplink)
analytics.appOpened(
  launchType: LaunchType.cold,
  coldStartMs: stopwatch.elapsedMilliseconds,
  referrerSource: ReferrerSource.deeplink,
  lastScreen: prefs.lastScreen,
);

// 2. Onboarding step completed
analytics.onboardingStepCompleted(
  stepIndex: 3, stepName: 'goal_selection',
  timeOnStepS: 12,
  payload: {'goal': '5k_under_30'},
);

// 3. Sign-in succeeded
analytics.signInSucceeded(
  method: SignInMethod.apple, isNewUser: false, latencyMs: 840,
);

// 4. Activity started
analytics.activityStarted(
  activityType: ActivityType.run,
  source: ActivitySource.gps,
  autoPauseEnabled: true,
  voiceCoachEnabled: true,
  audioProvider: AudioProvider.spotify,
  gpsAccuracyM: 5.4,
  weatherTempC: 28.5,
);

// 5. Activity saved
analytics.activitySaved(
  activityId: act.id,
  activityType: ActivityType.run,
  distanceM: act.distanceM,
  durationS: act.durationS,
  movingDurationS: act.movingS,
  avgPaceSPerKm: act.paceSPerKm,
  avgHrBpm: act.avgHr,
  caloriesKcal: act.kcal,
  elevationGainM: act.elevM,
  gpsQualityScore: act.gpsScore,
  autoPauseCount: act.autoPauses,
  manualPauseCount: act.manualPauses,
  titleSet: act.title.isNotEmpty,
  noteSet: act.note.isNotEmpty,
  photoCount: act.photos.length,
);

// 6. Paywall viewed
analytics.paywallViewed(
  placement: PaywallPlacement.post_workout,
  featureGated: null,
  offerId: 'annual_30off',
  experimentVariant: ff.getVariant('paywall_v3'),
);

// 7. Purchase succeeded
analytics.purchaseSucceeded(
  tier: Tier.pro, period: Period.annual,
  priceLocal: 999000, priceUsd: 39.5, currency: 'VND',
  paymentMethod: PaymentMethod.app_store,
  isTrialConversion: true, isRenewal: false,
  transactionIdHash: hashes.txn(receipt.transactionId),
);

// 8. AI message received
analytics.aiMessageReceived(
  conversationId: convo.id,
  latencyMs: response.latencyMs,
  tokensInput: response.usage.inputTokens,
  tokensOutput: response.usage.outputTokens,
  cachedTokens: response.usage.cacheReadInputTokens,
  cacheHitRatio: response.usage.cacheHitRatio,
  costUsd: response.cost,
  modelUsed: 'claude-haiku-4-5',
  streamed: true,
  toolCallsCount: response.toolCalls.length,
);

// 9. Badge earned
analytics.badgeEarned(
  badgeCode: 'first_10k',
  category: BadgeCategory.distance,
  tier: BadgeTier.silver,
  isFirstTime: true,
);

// 10. Subscription canceled
analytics.subscriptionCanceled(
  tier: Tier.pro, period: Period.annual,
  reasonCode: 'too_expensive',
  reasonFreeText: false,
  daysActive: 184,
  canceledInTrial: false,
);
```

---

## 8. CI lint

`runvie_analytics_lint` (a `custom_lint` package) enforces:

- Any literal string passed to `Posthog().capture` outside `AnalyticsService` is a compile error.
- Any string key containing `email|phone|birthday|address|raw_token` flagged.
- Any new method in `AnalyticsService` must be referenced in `events-spec.md` (build-time check via reflection on the generated file).
- All enum values match the spec.

---

## 9. Testing

```dart
test('activityStarted sends correct payload', () async {
  final mock = MockPosthog();
  AnalyticsService.instance.overrideForTest(posthog: mock);

  await AnalyticsService.instance.activityStarted(
    activityType: ActivityType.run,
    source: ActivitySource.gps,
    autoPauseEnabled: true,
    voiceCoachEnabled: false,
    gpsAccuracyM: 5.4,
  );

  verify(mock.capture(
    eventName: 'activity_started',
    properties: {
      'activity_type': 'run',
      'source': 'gps',
      'auto_pause_enabled': true,
      'voice_coach_enabled': false,
      'audio_provider': 'none',
      'gps_accuracy_m': 5.4,
    },
  )).called(1);
});
```

100% method coverage required for P0 events (CI gate).
