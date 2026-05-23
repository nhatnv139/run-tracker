import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:runvie/data/models/user_profile.dart';
import 'package:runvie/features/auth/providers/auth_providers.dart';

/// Loads the current user's profile row. Returns null when not signed in
/// or when the row doesn't exist yet (e.g. anonymous user pre-onboarding).
final FutureProvider<UserProfile?> userProfileProvider =
    FutureProvider<UserProfile?>((Ref ref) async {
  final User? user = ref.watch(currentUserProvider);
  if (user == null) return null;
  try {
    return await ref.watch(profileRepositoryProvider).fetchMe();
  } catch (_) {
    return null;
  }
});
