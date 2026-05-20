import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:runvie/data/repositories/auth_repository.dart';
import 'package:runvie/data/repositories/profile_repository.dart';

/// Single shared [AuthRepository]. Override in tests via [ProviderContainer].
final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((Ref ref) => AuthRepository());

final Provider<ProfileRepository> profileRepositoryProvider =
    Provider<ProfileRepository>((Ref ref) => ProfileRepository());

/// Streams Supabase auth state changes for the whole app to react to.
final StreamProvider<AuthState> authStateChangesProvider =
    StreamProvider<AuthState>((Ref ref) {
  final AuthRepository repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

/// Convenience: the currently signed-in user (or null), reactive.
final Provider<User?> currentUserProvider = Provider<User?>((Ref ref) {
  final AsyncValue<AuthState> async$ = ref.watch(authStateChangesProvider);
  return async$.maybeWhen(
    data: (AuthState s) => s.session?.user,
    orElse: () => ref.read(authRepositoryProvider).currentUser,
  );
});

/// True once we know whether the user is signed in (i.e. first auth event
/// arrived OR there is already a current user).
final Provider<bool> isSignedInProvider = Provider<bool>((Ref ref) {
  return ref.watch(currentUserProvider) != null;
});
