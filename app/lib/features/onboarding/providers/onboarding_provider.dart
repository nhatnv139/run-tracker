import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runvie/features/onboarding/models/onboarding_state.dart';

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void setGoal(RunGoal v) => state = state.copyWith(goal: v);
  void setLevel(RunLevel v) => state = state.copyWith(level: v);
  void setPersonal({
    double? weightKg,
    double? heightCm,
    int? age,
    Gender? gender,
  }) {
    state = state.copyWith(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
    );
  }

  void setNotificationsOptIn(bool v) =>
      state = state.copyWith(notificationsOptIn: v);
  void setPermissionGranted(bool v) =>
      state = state.copyWith(permissionGranted: v);
}

final NotifierProvider<OnboardingController, OnboardingState>
    onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
  OnboardingController.new,
);
