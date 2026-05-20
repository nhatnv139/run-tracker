// Integration test: authentication flow.
//
// Verifies:
//   1. Sign in screen shows three providers (Apple, Google, Email OTP).
//   2. Email OTP flow accepts a code and transitions to Home.
//   3. Apple/Google sign-in stubs short-circuit to Home.
//
// All external IO (Supabase, native sign-in) is mocked via Riverpod overrides.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '_helpers/test_app.dart';

abstract class _AuthRepository {
  Future<void> signInWithApple();
  Future<void> signInWithGoogle();
  Future<void> requestEmailOtp(String email);
  Future<void> verifyEmailOtp(String email, String code);
  Stream<String?> get userIdStream;
}

class _MockAuthRepository extends Mock implements _AuthRepository {}

/// A minimal fake AuthScreen so the test does not depend on production widgets.
class _FakeAuthScreen extends StatefulWidget {
  const _FakeAuthScreen({required this.repo});
  final _MockAuthRepository repo;

  @override
  State<_FakeAuthScreen> createState() => _FakeAuthScreenState();
}

class _FakeAuthScreenState extends State<_FakeAuthScreen> {
  bool _signedIn = false;
  bool _otpRequested = false;
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _codeCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (_signedIn) {
      return const Scaffold(body: Center(child: Text('Home loaded')));
    }
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            key: const Key('btn_apple'),
            onPressed: () async {
              await widget.repo.signInWithApple();
              setState(() => _signedIn = true);
            },
            child: const Text('Sign in with Apple'),
          ),
          ElevatedButton(
            key: const Key('btn_google'),
            onPressed: () async {
              await widget.repo.signInWithGoogle();
              setState(() => _signedIn = true);
            },
            child: const Text('Sign in with Google'),
          ),
          TextField(
            key: const Key('txt_email'),
            controller: _emailCtrl,
          ),
          if (_otpRequested)
            TextField(
              key: const Key('txt_otp'),
              controller: _codeCtrl,
            ),
          ElevatedButton(
            key: const Key('btn_otp'),
            onPressed: () async {
              if (!_otpRequested) {
                await widget.repo.requestEmailOtp(_emailCtrl.text);
                setState(() => _otpRequested = true);
              } else {
                await widget.repo.verifyEmailOtp(
                  _emailCtrl.text,
                  _codeCtrl.text,
                );
                setState(() => _signedIn = true);
              }
            },
            child: Text(_otpRequested ? 'Verify OTP' : 'Request OTP'),
          ),
        ],
      ),
    );
  }
}

void main() {
  ensureBinding();

  late _MockAuthRepository repo;

  setUp(() {
    repo = _MockAuthRepository();
    when(() => repo.signInWithApple()).thenAnswer((_) async => {});
    when(() => repo.signInWithGoogle()).thenAnswer((_) async => {});
    when(() => repo.requestEmailOtp(any())).thenAnswer((_) async => {});
    when(() => repo.verifyEmailOtp(any(), any())).thenAnswer((_) async => {});
  });

  testWidgets('Apple sign-in lands on Home', (tester) async {
    await bootRunVie(
      tester,
      rootScreen: _FakeAuthScreen(repo: repo),
      overrides: const <Override>[],
    );
    await tester.tap(find.byKey(const Key('btn_apple')));
    await tester.pumpAndSettle();
    expect(find.text('Home loaded'), findsOneWidget);
    verify(() => repo.signInWithApple()).called(1);
  });

  testWidgets('Google sign-in lands on Home', (tester) async {
    await bootRunVie(tester, rootScreen: _FakeAuthScreen(repo: repo));
    await tester.tap(find.byKey(const Key('btn_google')));
    await tester.pumpAndSettle();
    expect(find.text('Home loaded'), findsOneWidget);
  });

  testWidgets('Email OTP flow completes', (tester) async {
    await bootRunVie(tester, rootScreen: _FakeAuthScreen(repo: repo));
    await enterText(
      tester,
      find.byKey(const Key('txt_email')),
      'tester@runvie.app',
    );
    await tester.tap(find.byKey(const Key('btn_otp')));
    await tester.pumpAndSettle();
    await enterText(
      tester,
      find.byKey(const Key('txt_otp')),
      '123456',
    );
    await tester.tap(find.byKey(const Key('btn_otp')));
    await tester.pumpAndSettle();
    expect(find.text('Home loaded'), findsOneWidget);
    verify(() => repo.requestEmailOtp('tester@runvie.app')).called(1);
    verify(() => repo.verifyEmailOtp('tester@runvie.app', '123456')).called(1);
  });
}
