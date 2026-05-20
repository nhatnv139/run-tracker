// Shared helper to bootstrap RunVie inside an IntegrationTestWidgetsFlutterBinding.
//
// We intentionally do NOT import production lib/main.dart here so that we keep
// strict control over which providers are overridden during the integration
// test session. Each individual test should call [bootRunVie] with its own
// list of overrides (mocked Supabase client, mocked location stream, etc.).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Ensures the integration binding is initialised exactly once per test
/// process. Safe to call from every test's setUp.
IntegrationTestWidgetsFlutterBinding ensureBinding() {
  return IntegrationTestWidgetsFlutterBinding.ensureInitialized();
}

/// A neutral root widget that hosts a [ProviderScope] for tests.
///
/// In the real app `lib/app.dart` exposes the equivalent of [RunVieApp].
/// We mirror its name so navigation expectations stay readable.
class TestRunVieApp extends StatelessWidget {
  const TestRunVieApp({super.key, required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RunVie integration test',
      theme: ThemeData.light(useMaterial3: true),
      home: home,
    );
  }
}

/// Boots the app for a single integration test.
///
/// [overrides] are passed straight into the [ProviderScope], allowing each
/// test to swap real Supabase / Riverpod providers for mocktail doubles.
Future<void> bootRunVie(
  WidgetTester tester, {
  required Widget rootScreen,
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: TestRunVieApp(home: rootScreen),
    ),
  );
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

/// Convenience: tap by text then settle.
Future<void> tapText(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// Convenience: type into the first matching TextField.
Future<void> enterText(
  WidgetTester tester,
  Finder field,
  String value,
) async {
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
}
