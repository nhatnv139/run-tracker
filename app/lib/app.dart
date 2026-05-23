import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runvie/core/constants.dart';
import 'package:runvie/core/router/router.dart';
import 'package:runvie/core/theme/aurora_theme.dart';
import 'package:runvie/features/settings/models/app_settings.dart';
import 'package:runvie/features/settings/providers/settings_providers.dart';

class RunVieApp extends ConsumerWidget {
  const RunVieApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);
    final AppSettings settings =
        ref.watch(appSettingsProvider).valueOrNull ?? const AppSettings();
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AuroraTheme.light(),
      darkTheme: AuroraTheme.dark(),
      themeMode: settings.themeMode,
      routerConfig: router,
      locale: const Locale('vi', 'VN'),
      supportedLocales: const <Locale>[
        Locale('vi', 'VN'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
