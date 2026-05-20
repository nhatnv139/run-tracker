import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runvie/features/streak/streak_calc.dart';
import 'package:runvie/features/streak/streak_providers.dart';
import 'package:runvie/features/streak/streak_state.dart';

/// Watches the streak state and schedules a local push warning at 20:00
/// local if the user has an active streak but hasn't run today.
class StreakWarningService {
  StreakWarningService({
    required this.notifications,
    required this.calculator,
  });

  final FlutterLocalNotificationsPlugin notifications;
  final StreakCalculator calculator;

  /// Notification ID — stable so re-scheduling cancels the previous warning.
  static const int notificationId = 91001;

  Future<void> evaluate(StreakState state, {DateTime? now}) async {
    final DateTime instant = now ?? DateTime.now();
    final bool shouldNotify =
        calculator.shouldSendWarningPush(state, instant);
    if (!shouldNotify) return;
    final int days = state.currentDays;
    try {
      await notifications.show(
        notificationId,
        'Streak $days ngay sap dut!',
        'Chi can 1km de giu chuoi. Bat dau ngay bay gio!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'streak_warning',
            'Canh bao chuoi',
            channelDescription: 'Nhac khi streak sap dut',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: 'streak_warning',
      );
    } catch (e) {
      // The notifications plugin may not be initialised in tests/headless
      // mode — swallow the failure so callers don't have to guard.
      debugPrint('streak warning failed: $e');
    }
  }
}

/// Plugin instance is a singleton — provider keeps the wiring obvious.
final Provider<FlutterLocalNotificationsPlugin> notificationsPluginProvider =
    Provider<FlutterLocalNotificationsPlugin>(
  (Ref ref) => FlutterLocalNotificationsPlugin(),
);

final Provider<StreakWarningService> streakWarningServiceProvider =
    Provider<StreakWarningService>(
  (Ref ref) => StreakWarningService(
    notifications: ref.watch(notificationsPluginProvider),
    calculator: ref.watch(streakCalculatorProvider),
  ),
);

/// Bootstrap — fire-and-forget evaluation triggered on app start and
/// whenever the streak state changes.
final Provider<void> streakWarningListenerProvider = Provider<void>((Ref ref) {
  ref.listen<StreakState>(streakControllerProvider,
      (StreakState? prev, StreakState next) {
    unawaited(ref.read(streakWarningServiceProvider).evaluate(next));
  });
});
