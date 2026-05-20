import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:runvie/data/models/user_profile.dart';
import 'package:runvie/features/auth/auth_exception.dart';
import 'package:runvie/features/onboarding/models/onboarding_state.dart';
import 'package:runvie/services/supabase_service.dart';

/// Persists profile rows in the `profiles` table and devices in `devices`.
class ProfileRepository {
  ProfileRepository({SupabaseService? supabase})
      : _supabase = supabase ?? SupabaseService.instance;

  final SupabaseService _supabase;

  static const String _profilesTable = 'profiles';
  static const String _devicesTable = 'devices';

  /// Read the row for the current user, or null if none.
  Future<UserProfile?> fetchMe() async {
    final User? user = _supabase.currentUser;
    if (user == null) return null;
    final dynamic row = await _supabase.client
        .from(_profilesTable)
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (row == null) return null;
    return UserProfile.fromJson(Map<String, dynamic>.from(row as Map<dynamic, dynamic>));
  }

  /// Upsert the current user's profile row.
  Future<UserProfile> upsert(UserProfile profile) async {
    final User? user = _supabase.currentUser;
    if (user == null) throw AuthFailure.notSignedIn;
    final UserProfile withId = profile.copyWith(
      id: user.id,
      email: profile.email ?? user.email,
      updatedAt: DateTime.now().toUtc(),
    );
    final dynamic row = await _supabase.client
        .from(_profilesTable)
        .upsert(withId.toJson())
        .select()
        .single();
    return UserProfile.fromJson(Map<String, dynamic>.from(row as Map<dynamic, dynamic>));
  }

  /// Build a payload from onboarding state and upsert it, flipping
  /// `onboarded` to true. Returns the persisted row.
  Future<UserProfile> completeOnboarding(OnboardingState onboarding) async {
    final User? user = _supabase.currentUser;
    if (user == null) throw AuthFailure.notSignedIn;
    final UserProfile profile = buildProfilePayload(
      userId: user.id,
      email: user.email,
      displayName: user.userMetadata?['name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      onboarding: onboarding,
      onboarded: true,
    );
    return upsert(profile);
  }

  /// Pure helper extracted for unit tests — no I/O.
  static UserProfile buildProfilePayload({
    required String userId,
    String? email,
    String? displayName,
    String? avatarUrl,
    required OnboardingState onboarding,
    bool onboarded = true,
  }) {
    return UserProfile(
      id: userId,
      email: email,
      displayName: displayName,
      avatarUrl: avatarUrl,
      goal: onboarding.goal?.name,
      level: onboarding.level?.name,
      weightKg: onboarding.weightKg,
      heightCm: onboarding.heightCm,
      age: onboarding.age,
      gender: onboarding.gender?.name,
      onboarded: onboarded,
    );
  }

  /// Register a push token row in `devices` keyed by (user_id, token).
  Future<void> registerDevice({
    required String pushToken,
    required String platform,
    String? apnsToken,
  }) async {
    final User? user = _supabase.currentUser;
    if (user == null) throw AuthFailure.notSignedIn;
    await _supabase.client.from(_devicesTable).upsert(<String, dynamic>{
      'user_id': user.id,
      'push_token': pushToken,
      if (apnsToken != null) 'apns_token': apnsToken,
      'platform': platform,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
