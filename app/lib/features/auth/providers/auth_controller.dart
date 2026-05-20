import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runvie/data/repositories/auth_repository.dart';
import 'package:runvie/features/auth/auth_exception.dart';
import 'package:runvie/features/auth/providers/auth_providers.dart';

@immutable
class AuthUiState {
  const AuthUiState({
    this.loading = false,
    this.pendingEmail,
    this.otpRequested = false,
    this.failure,
  });

  /// True while any auth-network call is in flight.
  final bool loading;

  /// Email currently in OTP flow. Persisted so the verify screen knows where
  /// to send the code back to.
  final String? pendingEmail;

  /// Whether we've already shipped a code to [pendingEmail].
  final bool otpRequested;

  final AuthFailure? failure;

  AuthUiState copyWith({
    bool? loading,
    String? pendingEmail,
    bool? otpRequested,
    AuthFailure? failure,
    bool clearFailure = false,
    bool clearPendingEmail = false,
  }) {
    return AuthUiState(
      loading: loading ?? this.loading,
      pendingEmail:
          clearPendingEmail ? null : (pendingEmail ?? this.pendingEmail),
      otpRequested: otpRequested ?? this.otpRequested,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

class AuthController extends Notifier<AuthUiState> {
  @override
  AuthUiState build() => const AuthUiState();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<bool> signInWithGoogle() async {
    return _guard(() async {
      await _repo.signInWithGoogle();
    });
  }

  Future<bool> signInWithApple() async {
    return _guard(() async {
      await _repo.signInWithApple();
    });
  }

  Future<bool> signInAnonymously() async {
    return _guard(() async {
      await _repo.signInAnonymously();
    });
  }

  Future<bool> requestOtp(String email) async {
    return _guard(() async {
      await _repo.requestEmailOtp(email);
      state = state.copyWith(
        pendingEmail: email.trim().toLowerCase(),
        otpRequested: true,
      );
    });
  }

  Future<bool> verifyOtp(String code) async {
    final String? email = state.pendingEmail;
    if (email == null) {
      state = state.copyWith(failure: AuthFailure.invalidEmail);
      return false;
    }
    return _guard(() async {
      await _repo.verifyEmailOtp(email: email, token: code);
      state = state.copyWith(
        clearPendingEmail: true,
        otpRequested: false,
      );
    });
  }

  Future<void> signOut() async {
    state = state.copyWith(loading: true, clearFailure: true);
    await _repo.signOut();
    state = const AuthUiState();
  }

  Future<bool> deleteAccount() async {
    return _guard(() async {
      await _repo.deleteAccount();
    });
  }

  void clearError() {
    state = state.copyWith(clearFailure: true);
  }

  Future<bool> _guard(Future<void> Function() action) async {
    state = state.copyWith(loading: true, clearFailure: true);
    try {
      await action();
      state = state.copyWith(loading: false);
      return true;
    } on AuthFailure catch (e) {
      state = state.copyWith(loading: false, failure: e);
      return false;
    } catch (_) {
      state = state.copyWith(loading: false, failure: AuthFailure.unknown);
      return false;
    }
  }
}

final NotifierProvider<AuthController, AuthUiState> authControllerProvider =
    NotifierProvider<AuthController, AuthUiState>(AuthController.new);
