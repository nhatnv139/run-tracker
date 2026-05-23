import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runvie/core/router/routes.dart';
import 'package:runvie/features/activity/presentation/activity_detail_screen.dart';
import 'package:runvie/features/activity/presentation/activity_screen.dart';
import 'package:runvie/features/auth/presentation/email_otp_screen.dart';
import 'package:runvie/features/auth/presentation/email_otp_verify_screen.dart';
import 'package:runvie/features/auth/presentation/sign_in_screen.dart';
import 'package:runvie/features/ai_coach/presentation/ai_coach_screen.dart';
import 'package:runvie/features/badges/presentation/badges_screen.dart';
import 'package:runvie/features/coins/presentation/marketplace_screen.dart';
import 'package:runvie/features/coins/presentation/transaction_history_screen.dart';
import 'package:runvie/features/coins/presentation/wallet_screen.dart';
import 'package:runvie/features/home/presentation/home_screen.dart';
import 'package:runvie/features/paywall/paywall_placement.dart';
import 'package:runvie/features/paywall/presentation/paywall_screen.dart';
import 'package:runvie/features/onboarding/presentation/goal_screen.dart';
import 'package:runvie/features/onboarding/presentation/level_screen.dart';
import 'package:runvie/features/onboarding/presentation/notification_screen.dart';
import 'package:runvie/features/onboarding/presentation/paywall_screen.dart';
import 'package:runvie/features/onboarding/presentation/permission_screen.dart';
import 'package:runvie/features/onboarding/presentation/personalize_screen.dart';
import 'package:runvie/features/onboarding/presentation/welcome_screen.dart';
import 'package:runvie/features/plan/presentation/full_plan_screen.dart';
import 'package:runvie/features/plan/presentation/plan_screen.dart';
import 'package:runvie/features/profile/presentation/edit_profile_screen.dart';
import 'package:runvie/features/profile/presentation/profile_screen.dart';
import 'package:runvie/features/run/presentation/post_run_screen.dart';
import 'package:runvie/features/run/presentation/run_screen.dart';
import 'package:runvie/features/settings/presentation/settings_screen.dart';
import 'package:runvie/features/social/presentation/social_screen.dart';
import 'package:runvie/features/streak/presentation/streak_screen.dart';
import 'package:runvie/features/subscription/presentation/manage_subscription_screen.dart';
import 'package:runvie/shared/widgets/main_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavKey = GlobalKey<NavigatorState>();

final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  return GoRouter(
    navigatorKey: _rootNavKey,
    initialLocation: AppRoutes.onboardingWelcome,
    debugLogDiagnostics: false,
    routes: <RouteBase>[
      // Onboarding
      GoRoute(
        path: AppRoutes.onboardingWelcome,
        builder: (BuildContext context, GoRouterState state) =>
            const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingGoal,
        builder: (BuildContext context, GoRouterState state) =>
            const GoalScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingLevel,
        builder: (BuildContext context, GoRouterState state) =>
            const LevelScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingPersonalize,
        builder: (BuildContext context, GoRouterState state) =>
            const PersonalizeScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingNotification,
        builder: (BuildContext context, GoRouterState state) =>
            const NotificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingPermission,
        builder: (BuildContext context, GoRouterState state) =>
            const PermissionScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingPaywall,
        builder: (BuildContext context, GoRouterState state) =>
            const PaywallScreen(),
      ),

      // Auth
      GoRoute(
        path: AppRoutes.signIn,
        builder: (BuildContext context, GoRouterState state) =>
            const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.emailOtp,
        builder: (BuildContext context, GoRouterState state) =>
            const EmailOtpScreen(),
      ),
      GoRoute(
        path: AppRoutes.emailOtpVerify,
        builder: (BuildContext context, GoRouterState state) =>
            const EmailOtpVerifyScreen(),
      ),

      // Modal full-screen
      GoRoute(
        path: AppRoutes.run,
        parentNavigatorKey: _rootNavKey,
        builder: (BuildContext context, GoRouterState state) =>
            const RunScreen(),
      ),
      GoRoute(
        path: AppRoutes.badges,
        parentNavigatorKey: _rootNavKey,
        builder: (BuildContext context, GoRouterState state) =>
            const BadgesScreen(),
      ),
      GoRoute(
        path: AppRoutes.social,
        parentNavigatorKey: _rootNavKey,
        builder: (BuildContext context, GoRouterState state) =>
            const SocialScreen(),
      ),

      // AI Coach
      GoRoute(
        path: AppRoutes.aiCoach,
        parentNavigatorKey: _rootNavKey,
        builder: (BuildContext context, GoRouterState state) =>
            const AiCoachScreen(),
      ),

      // Streak
      GoRoute(
        path: AppRoutes.streak,
        parentNavigatorKey: _rootNavKey,
        builder: (BuildContext context, GoRouterState state) =>
            const StreakScreen(),
      ),

      // Wallet / RunCoin
      GoRoute(
        path: AppRoutes.wallet,
        parentNavigatorKey: _rootNavKey,
        builder: (BuildContext context, GoRouterState state) =>
            const WalletScreen(),
      ),
      GoRoute(
        path: AppRoutes.marketplace,
        parentNavigatorKey: _rootNavKey,
        builder: (BuildContext context, GoRouterState state) =>
            const MarketplaceScreen(),
      ),
      GoRoute(
        path: AppRoutes.transactions,
        parentNavigatorKey: _rootNavKey,
        builder: (BuildContext context, GoRouterState state) =>
            const TransactionHistoryScreen(),
      ),

      // Activity detail / Post-run
      GoRoute(
        path: AppRoutes.activityDetail,
        parentNavigatorKey: _rootNavKey,
        builder: (BuildContext context, GoRouterState state) {
          final int id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return ActivityDetailScreen(activityId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.postRun,
        parentNavigatorKey: _rootNavKey,
        builder: (BuildContext context, GoRouterState state) {
          final int id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return PostRunScreen(activityId: id);
        },
      ),

      // Plan full view
      GoRoute(
        path: AppRoutes.planFull,
        parentNavigatorKey: _rootNavKey,
        builder: (BuildContext context, GoRouterState state) =>
            const FullPlanScreen(),
      ),

      // Profile / Settings
      GoRoute(
        path: AppRoutes.editProfile,
        parentNavigatorKey: _rootNavKey,
        builder: (BuildContext context, GoRouterState state) =>
            const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        parentNavigatorKey: _rootNavKey,
        builder: (BuildContext context, GoRouterState state) =>
            const SettingsScreen(),
      ),

      // Paywall / Subscription
      GoRoute(
        path: AppRoutes.paywall,
        parentNavigatorKey: _rootNavKey,
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          final PaywallPlacement placement = extra is PaywallPlacement
              ? extra
              : PaywallPlacement.featureGate;
          return PaywallContextualScreen(placement: placement);
        },
      ),
      GoRoute(
        path: AppRoutes.manageSubscription,
        parentNavigatorKey: _rootNavKey,
        builder: (BuildContext context, GoRouterState state) =>
            const ManageSubscriptionScreen(),
      ),

      // Main tabs (bottom nav)
      ShellRoute(
        navigatorKey: _shellNavKey,
        builder: (BuildContext context, GoRouterState state, Widget child) =>
            MainScaffold(child: child),
        routes: <RouteBase>[
          GoRoute(
            path: AppRoutes.home,
            builder: (BuildContext context, GoRouterState state) =>
                const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.activity,
            builder: (BuildContext context, GoRouterState state) =>
                const ActivityScreen(),
          ),
          GoRoute(
            path: AppRoutes.plan,
            builder: (BuildContext context, GoRouterState state) =>
                const PlanScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (BuildContext context, GoRouterState state) =>
                const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
