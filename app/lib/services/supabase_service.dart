import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin facade over [Supabase.instance.client].
///
/// Concentrates every call we make against Supabase auth so unit tests can
/// stub one seam (the [SupabaseClient]) and the rest of the app can stay
/// transport-agnostic.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  /// Test seam: an override pushed in via [debugSetClient] takes priority
  /// over the real singleton. Allows widget tests to run without bringing
  /// up real Supabase.
  static SupabaseClient? _override;

  // ignore: avoid_setters_without_getters
  static set debugClient(SupabaseClient? c) => _override = c;

  SupabaseClient get client => _override ?? Supabase.instance.client;

  bool get isSignedIn => client.auth.currentSession != null;
  User? get currentUser => client.auth.currentUser;
  Session? get currentSession => client.auth.currentSession;
  Stream<AuthState> get onAuthStateChange => client.auth.onAuthStateChange;

  // ------------------------------------------------------------------
  // Email / password (kept for backwards compat with sync_service).
  // ------------------------------------------------------------------
  Future<AuthResponse> signInWithEmail(String email, String password) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  // ------------------------------------------------------------------
  // OTP / Magic link.
  // ------------------------------------------------------------------
  Future<void> sendEmailOtp(String email) {
    return client.auth.signInWithOtp(
      email: email,
      shouldCreateUser: true,
    );
  }

  Future<AuthResponse> verifyEmailOtp({
    required String email,
    required String token,
  }) {
    return client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
  }

  // ------------------------------------------------------------------
  // OAuth via ID token (Google / Apple).
  // ------------------------------------------------------------------
  Future<AuthResponse> signInWithGoogleIdToken({
    required String idToken,
    String? accessToken,
    String? nonce,
  }) {
    return client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
      nonce: nonce,
    );
  }

  Future<AuthResponse> signInWithAppleIdToken({
    required String idToken,
    required String nonce,
  }) {
    return client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: nonce,
    );
  }

  // ------------------------------------------------------------------
  // Anonymous.
  // ------------------------------------------------------------------
  Future<AuthResponse> signInAnonymously() => client.auth.signInAnonymously();

  // ------------------------------------------------------------------
  // Sign out / delete.
  // ------------------------------------------------------------------
  Future<void> signOut() => client.auth.signOut();

  /// Calls the Supabase RPC `delete_user_account` which must be defined
  /// server-side to scrub the row + delete the auth user.
  Future<void> deleteAccount() async {
    await client.rpc<dynamic>('delete_user_account');
  }

  // ------------------------------------------------------------------
  // Nonce helpers used by Apple sign-in.
  // ------------------------------------------------------------------
  static String generateRawNonce([int length = 32]) {
    const String charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
    final Random rnd = Random.secure();
    return List<String>.generate(
      length,
      (_) => charset[rnd.nextInt(charset.length)],
    ).join();
  }

  static String sha256OfString(String input) {
    final List<int> bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }
}
