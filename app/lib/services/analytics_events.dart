/// Centralized analytics event names. Keep snake_case + stable strings —
/// renaming an event breaks historical dashboards.
class AnalyticsEvents {
  AnalyticsEvents._();

  // App lifecycle
  static const String appLaunched = 'app_launched';
  static const String appBackgrounded = 'app_backgrounded';
  static const String appForegrounded = 'app_foregrounded';

  // Onboarding
  static const String onboardingStarted = 'onboarding_started';
  static const String onboardingStepViewed = 'onboarding_step_viewed';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String onboardingSkipped = 'onboarding_skipped';

  // Auth
  static const String signedIn = 'signed_in';
  static const String signedOut = 'signed_out';
  static const String signInFailed = 'sign_in_failed';

  // Run flow
  static const String runStarted = 'run_started';
  static const String runPaused = 'run_paused';
  static const String runResumed = 'run_resumed';
  static const String runAutoPaused = 'run_auto_paused';
  static const String runFinished = 'run_finished';
  static const String runDiscarded = 'run_discarded';

  // Activity
  static const String activitySaved = 'activity_saved';
  static const String activityViewed = 'activity_viewed';
  static const String activityShared = 'activity_shared';
  static const String activityDeleted = 'activity_deleted';
  static const String gpxExported = 'gpx_exported';
  static const String rpeRecorded = 'rpe_recorded';

  // Gamification
  static const String badgeUnlocked = 'badge_unlocked';
  static const String streakContinued = 'streak_continued';
  static const String streakBroken = 'streak_broken';
  static const String streakFreezeUsed = 'streak_freeze_used';
  static const String coinsEarned = 'coins_earned';
  static const String coinsRedeemed = 'coins_redeemed';

  // Monetization
  static const String paywallViewed = 'paywall_viewed';
  static const String paywallDismissed = 'paywall_dismissed';
  static const String paywallPurchased = 'paywall_purchased';
  static const String subscriptionStarted = 'subscription_started';
  static const String subscriptionCancelled = 'subscription_cancelled';
  static const String trialStarted = 'trial_started';
  static const String trialEnded = 'trial_ended';

  // Training plan
  static const String planStarted = 'plan_started';
  static const String planWorkoutCompleted = 'plan_workout_completed';
  static const String planWorkoutSkipped = 'plan_workout_skipped';
  static const String planCancelled = 'plan_cancelled';

  // AI Coach
  static const String aiCoachOpened = 'ai_coach_opened';
  static const String aiCoachMessageSent = 'ai_coach_message_sent';
  static const String voiceCoachPlayed = 'voice_coach_played';
  static const String voiceCoachToggled = 'voice_coach_toggled';

  // Settings
  static const String settingsChanged = 'settings_changed';
  static const String themeChanged = 'theme_changed';
  static const String voiceGenderChanged = 'voice_gender_changed';

  // Screens (used with AnalyticsService.screen)
  static const String screenHome = 'home';
  static const String screenActivity = 'activity';
  static const String screenActivityDetail = 'activity_detail';
  static const String screenRun = 'run';
  static const String screenPostRun = 'post_run';
  static const String screenPlan = 'plan';
  static const String screenProfile = 'profile';
  static const String screenSettings = 'settings';
  static const String screenPaywall = 'paywall';
  static const String screenAiCoach = 'ai_coach';
  static const String screenBadges = 'badges';
  static const String screenWallet = 'wallet';
  static const String screenStreak = 'streak';
}
