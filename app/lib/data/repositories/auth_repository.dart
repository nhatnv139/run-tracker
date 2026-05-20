import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:runvie/features/auth/auth_exception.dart';
import 'package:runvie/services/supabase_service.dart';

/// Abstraction over the third-party sign-in plugins so tests can stub them.
abstract class GoogleAuthClient {
  Future<GoogleSignInUser?> signInForIdToken();
  Future<void> signOut();
}

class GoogleSignInUser {
  const GoogleSignInUser({required this.idToken, this.accessToken, this.email});
  final String idToken;
  final String? accessToken;
  final String? email;
}

class _DefaultGoogleAuthClient implements GoogleAuthClient {
  _DefaultGoogleAuthClient({String? serverClientId})
      : _signIn = GoogleSignIn(serverClientId: serverClientId);

  final GoogleSignIn _signIn;

  @override
  Future<GoogleSignInUser?> signInForIdToken() async {
    final GoogleSignInAccount? account = await _signIn.signIn();
    if (account == null) return null;
    final GoogleSignInAuthentication auth = await account.authentication;
    final String? idToken = auth.idToken;
    if (idToken == null) {
      throw AuthFailure.missingIdToken;
    }
    return GoogleSignInUser(
      idToken: idToken,
      accessToken: auth.accessToken,
      email: account.email,
    );
  }

  @override
  Future<void> signOut() => _signIn.signOut();
}

abstract class AppleAuthClient {
  Future<AppleSignInPayload> signIn({required String nonceSha256});
}

class AppleSignInPayload {
  const AppleSignInPayload({
    required this.identityToken,
    required this.rawNonce,
    this.email,
  });
  final String identityToken;
  final String rawNonce;
  final String? email;
}

class _DefaultAppleAuthClient implements AppleAuthClient {
  const _DefaultAppleAuthClient(this._rawNonce);

  final String _rawNonce;

  @override
  Future<AppleSignInPayload> signIn({required String nonceSha256}) async {
    final AuthorizationCredentialAppleID credential =
        await SignInWithApple.getAppleIDCredential(
      scopes: <AppleIDAuthorizationScopes>[
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonceSha256,
    );
    final String? idToken = credential.identityToken;
    if (idToken == null) throw AuthFailure.missingIdToken;
    return AppleSignInPayload(
      identityToken: idToken,
      rawNonce: _rawNonce,
      email: credential.email,
    );
  }
}

/// Secure-storage keys used by the repo.
class AuthStorageKeys {
  AuthStorageKeys._();
  static const String refreshToken = 'runvie.auth.refresh_token';
  static const String userId = 'runvie.auth.user_id';
}

/// Coordinates third-party providers + Supabase auth + secure storage.
class AuthRepository {
  AuthRepository({
    SupabaseService? supabase,
    GoogleAuthClient? google,
    AppleAuthClient Function(String rawNonce)? appleFactory,
    FlutterSecureStorage? storage,
    bool Function()? isApplePlatform,
  })  : _supabase = supabase ?? SupabaseService.instance,
        _google = google ?? _DefaultGoogleAuthClient(),
        _appleFactory =
            appleFactory ?? ((String rawNonce) => _DefaultAppleAuthClient(rawNonce)),
        _storage = storage ?? const FlutterSecureStorage(),
        _isApplePlatform = isApplePlatform ?? _defaultIsApplePlatform;

  final SupabaseService _supabase;
  final GoogleAuthClient _google;
  final AppleAuthClient Function(String rawNonce) _appleFactory;
  final FlutterSecureStorage _storage;
  final bool Function() _isApplePlatform;

  static bool _defaultIsApplePlatform() {
    if (kIsWeb) return false;
    try {
      return Platform.isIOS || Platform.isMacOS;
    } catch (_) {
      return false;
    }
  }

  bool get isApplePlatform => _isApplePlatform();
  bool get isSignedIn => _supabase.isSignedIn;
  User? get currentUser => _supabase.currentUser;
  Stream<AuthState> get authStateChanges => _supabase.onAuthStateChange;

  // ------------------------------------------------------------------
  // Google.
  // ------------------------------------------------------------------
  Future<AuthResponse> signInWithGoogle() async {
    try {
      final GoogleSignInUser? user = await _google.signInForIdToken();
      if (user == null) throw AuthFailure.cancelled;
      final AuthResponse response = await _supabase.signInWithGoogleIdToken(
        idToken: user.idToken,
        accessToken: user.accessToken,
      );
      await _persistSession(response.session);
      return response;
    } on AuthFailure {
      rethrow;
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (_) {
      throw AuthFailure.unknown;
    }
  }

  // ------------------------------------------------------------------
  // Apple.
  // ------------------------------------------------------------------
  Future<AuthResponse> signInWithApple() async {
    if (!isApplePlatform) {
      throw AuthFailure.providerUnavailable;
    }
    try {
      final String rawNonce = SupabaseService.generateRawNonce();
      final String hashedNonce = SupabaseService.sha256OfString(rawNonce);
      final AppleAuthClient client = _appleFactory(rawNonce);
      final AppleSignInPayload payload =
          await client.signIn(nonceSha256: hashedNonce);
      final AuthResponse response = await _supabase.signInWithAppleIdToken(
        idToken: payload.identityToken,
        nonce: payload.rawNonce,
      );
      await _persistSession(response.session);
      return response;
    } on AuthFailure {
      rethrow;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw AuthFailure.cancelled;
      }
      throw AuthFailure.providerUnavailable;
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (_) {
      throw AuthFailure.unknown;
    }
  }

  // ------------------------------------------------------------------
  // Email OTP.
  // ------------------------------------------------------------------
  Future<void> requestEmailOtp(String email) async {
    final String normalized = email.trim().toLowerCase();
    if (!_isProbablyEmail(normalized)) {
      throw AuthFailure.invalidEmail;
    }
    try {
      await _supabase.sendEmailOtp(normalized);
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (_) {
      throw AuthFailure.unknown;
    }
  }

  Future<AuthResponse> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    final String code = token.trim();
    if (code.length < 6) throw AuthFailure.invalidOtp;
    try {
      final AuthResponse response = await _supabase.verifyEmailOtp(
        email: email.trim().toLowerCase(),
        token: code,
      );
      await _persistSession(response.session);
      return response;
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (_) {
      throw AuthFailure.invalidOtp;
    }
  }

  // ------------------------------------------------------------------
  // Anonymous.
  // ------------------------------------------------------------------
  Future<AuthResponse> signInAnonymously() async {
    try {
      final AuthResponse response = await _supabase.signInAnonymously();
      await _persistSession(response.session);
      return response;
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (_) {
      throw AuthFailure.unknown;
    }
  }

  // ------------------------------------------------------------------
  // Sign out + delete.
  // ------------------------------------------------------------------
  Future<void> signOut() async {
    try {
      await _supabase.signOut();
    } catch (_) {
      // Even if remote sign-out fails we still clear local creds.
    }
    try {
      await _google.signOut();
    } catch (_) {
      /* not signed in via google */
    }
    await _clearStorage();
  }

  Future<void> deleteAccount() async {
    if (!_supabase.isSignedIn) {
      throw AuthFailure.notSignedIn;
    }
    try {
      await _supabase.deleteAccount();
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (_) {
      throw AuthFailure.unknown;
    }
    await signOut();
  }

  // ------------------------------------------------------------------
  // Storage helpers.
  // ------------------------------------------------------------------
  Future<void> _persistSession(Session? session) async {
    if (session == null) return;
    await _storage.write(
      key: AuthStorageKeys.refreshToken,
      value: session.refreshToken,
    );
    await _storage.write(
      key: AuthStorageKeys.userId,
      value: session.user.id,
    );
  }

  Future<void> _clearStorage() async {
    await _storage.delete(key: AuthStorageKeys.refreshToken);
    await _storage.delete(key: AuthStorageKeys.userId);
  }

  Future<String?> readPersistedRefreshToken() {
    return _storage.read(key: AuthStorageKeys.refreshToken);
  }

  // ------------------------------------------------------------------
  // Helpers.
  // ------------------------------------------------------------------
  static bool _isProbablyEmail(String s) {
    final RegExp re = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    return re.hasMatch(s);
  }

  AuthFailure _mapAuthException(AuthException e) {
    final String msg = e.message.toLowerCase();
    if (msg.contains('network') || msg.contains('connection')) {
      return AuthFailure.network;
    }
    if (msg.contains('otp') || msg.contains('token')) {
      return AuthFailure.invalidOtp;
    }
    return AuthFailure('supabase_${e.statusCode ?? ''}', e.message);
  }
}
