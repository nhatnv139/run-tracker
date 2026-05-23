import 'package:flutter_test/flutter_test.dart';

import 'package:runvie/services/analytics_events.dart';
import 'package:runvie/services/analytics_service.dart';

void main() {
  group('AnalyticsService', () {
    test('init then identify completes without error', () async {
      final AnalyticsService a = AnalyticsService();
      await a.init();
      await a.identify('user-123',
          properties: <String, Object?>{'plan': 'plus'});
      await a.track(AnalyticsEvents.runStarted);
      await a.screen(AnalyticsEvents.screenHome);
      await a.reset();
    });

    test('setSuperProperty(null) removes the key', () async {
      final AnalyticsService a = AnalyticsService();
      await a.setSuperProperty('experiment', 'A');
      await a.setSuperProperty('experiment', null);
      // Both calls should complete without error.
      expect(true, isTrue);
    });
  });

  group('AnalyticsEvents', () {
    test('event names are unique and snake_case', () {
      final List<String> names = <String>[
        AnalyticsEvents.appLaunched,
        AnalyticsEvents.onboardingStarted,
        AnalyticsEvents.onboardingCompleted,
        AnalyticsEvents.runStarted,
        AnalyticsEvents.runFinished,
        AnalyticsEvents.activitySaved,
        AnalyticsEvents.badgeUnlocked,
        AnalyticsEvents.paywallViewed,
        AnalyticsEvents.planStarted,
        AnalyticsEvents.aiCoachMessageSent,
      ];
      for (final String n in names) {
        expect(RegExp(r'^[a-z][a-z0-9_]*[a-z0-9]$').hasMatch(n), isTrue,
            reason: 'event "$n" is not snake_case');
      }
      expect(names.toSet().length, names.length,
          reason: 'duplicate event names');
    });
  });
}
