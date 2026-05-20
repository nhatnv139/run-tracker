/// App-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'RunVie';
  static const String defaultLocale = 'vi_VN';
  static const String distanceUnit = 'km';

  // Onboarding
  static const int onboardingSteps = 7;

  // GPS sampling
  static const double gpsAccuracyThresholdMeters = 25;
  static const Duration gpsIntervalForeground = Duration(seconds: 1);
  static const Duration gpsIntervalBackground = Duration(seconds: 2);

  // Run
  static const double minMovingSpeedMps = 0.6; // ~2.2 km/h, below = paused
  static const double maxPlausibleSpeedMps = 12; // ~43 km/h, reject above

  // Auto-pause
  static const Duration autoPauseGrace = Duration(seconds: 6);

  // Voice coach cues
  static const double cueIntervalKm = 1.0;
}
