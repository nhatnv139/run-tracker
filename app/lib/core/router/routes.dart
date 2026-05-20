/// All named routes in one place — typed access.
class AppRoutes {
  AppRoutes._();

  // Onboarding flow
  static const String onboardingWelcome = '/onboarding/welcome';
  static const String onboardingGoal = '/onboarding/goal';
  static const String onboardingLevel = '/onboarding/level';
  static const String onboardingPersonalize = '/onboarding/personalize';
  static const String onboardingNotification = '/onboarding/notification';
  static const String onboardingPermission = '/onboarding/permission';
  static const String onboardingPaywall = '/onboarding/paywall';

  // Auth
  static const String signIn = '/auth/sign-in';
  static const String emailOtp = '/auth/email-otp';
  static const String emailOtpVerify = '/auth/email-otp/verify';

  // Main tabs
  static const String home = '/home';
  static const String activity = '/activity';
  static const String plan = '/plan';
  static const String profile = '/profile';

  // Modal
  static const String run = '/run';
  static const String badges = '/badges';
  static const String social = '/social';

  // AI Coach
  static const String aiCoach = '/ai-coach';

  // Gamification
  static const String streak = '/streak';
  static const String wallet = '/wallet';
  static const String marketplace = '/wallet/marketplace';
  static const String transactions = '/wallet/transactions';

  // Subscription / paywall
  static const String paywall = '/paywall';
  static const String manageSubscription = '/subscription/manage';
}
