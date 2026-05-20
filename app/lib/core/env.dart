import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Typed env access. Load via [Env.load] before use.
class Env {
  Env._();

  static Future<void> load() async {
    await dotenv.load();
  }

  static String get supabaseUrl =>
      dotenv.maybeGet('SUPABASE_URL') ?? const String.fromEnvironment('SUPABASE_URL');

  static String get supabaseAnonKey =>
      dotenv.maybeGet('SUPABASE_ANON_KEY') ??
      const String.fromEnvironment('SUPABASE_ANON_KEY');

  static String? get sentryDsn => dotenv.maybeGet('SENTRY_DSN');

  static bool get enableVoiceCoach =>
      (dotenv.maybeGet('ENABLE_VOICE_COACH') ?? 'true').toLowerCase() == 'true';

  static bool get enableBackgroundGps =>
      (dotenv.maybeGet('ENABLE_BACKGROUND_GPS') ?? 'true').toLowerCase() == 'true';
}
