import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:runvie/app.dart';
import 'package:runvie/core/env.dart';
import 'package:runvie/services/analytics_events.dart';
import 'package:runvie/services/analytics_service.dart';
import 'package:runvie/services/error_reporting_service.dart';

Future<void> main() async {
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    final ErrorReportingService errors = ErrorReportingService();
    await errors.init();

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      errors.captureException(details.exception, stack: details.stack);
    };
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      errors.captureException(error, stack: stack);
      return true;
    };

    // Lock portrait for MVP.
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);

    // Load .env (silent if missing — handled in Env getters).
    try {
      await Env.load();
    } catch (_) {
      // .env not present in some build configs; continue.
    }

    // Local storage
    await Hive.initFlutter();

    // Supabase — only init if config present.
    if (Env.supabaseUrl.isNotEmpty && Env.supabaseAnonKey.isNotEmpty) {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
        debug: false,
      );
    }

    final AnalyticsService analytics = AnalyticsService();
    await analytics.init();
    unawaited(analytics.track(AnalyticsEvents.appLaunched));

    runApp(
      ProviderScope(
        overrides: <Override>[
          analyticsProvider.overrideWithValue(analytics),
          errorReportingProvider.overrideWithValue(errors),
        ],
        child: const RunVieApp(),
      ),
    );
  }, (Object error, StackTrace stack) {
    if (kDebugMode) {
      debugPrint('[uncaught] $error\n$stack');
    }
  });
}
