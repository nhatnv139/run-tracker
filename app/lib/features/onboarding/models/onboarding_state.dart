import 'package:flutter/foundation.dart';

/// Snapshot of every choice the user makes during onboarding.
///
/// Hand-written immutable data class shaped like a Freezed model
/// (copyWith + value-equality + toMap). Kept hand-written so the project
/// does not need a build_runner step on first install.
@immutable
class OnboardingState {
  const OnboardingState({
    this.goal,
    this.level,
    this.weightKg,
    this.heightCm,
    this.age,
    this.gender,
    this.notificationsOptIn = false,
    this.permissionGranted = false,
    this.pushToken,
    this.apnsToken,
  });

  final RunGoal? goal;
  final RunLevel? level;
  final double? weightKg;
  final double? heightCm;
  final int? age;
  final Gender? gender;
  final bool notificationsOptIn;
  final bool permissionGranted;
  final String? pushToken;
  final String? apnsToken;

  OnboardingState copyWith({
    RunGoal? goal,
    RunLevel? level,
    double? weightKg,
    double? heightCm,
    int? age,
    Gender? gender,
    bool? notificationsOptIn,
    bool? permissionGranted,
    String? pushToken,
    String? apnsToken,
  }) {
    return OnboardingState(
      goal: goal ?? this.goal,
      level: level ?? this.level,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      notificationsOptIn: notificationsOptIn ?? this.notificationsOptIn,
      permissionGranted: permissionGranted ?? this.permissionGranted,
      pushToken: pushToken ?? this.pushToken,
      apnsToken: apnsToken ?? this.apnsToken,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'goal': goal?.name,
        'level': level?.name,
        'weight_kg': weightKg,
        'height_cm': heightCm,
        'age': age,
        'gender': gender?.name,
        'notifications_opt_in': notificationsOptIn,
        'permission_granted': permissionGranted,
        if (pushToken != null) 'push_token': pushToken,
        if (apnsToken != null) 'apns_token': apnsToken,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingState &&
        other.goal == goal &&
        other.level == level &&
        other.weightKg == weightKg &&
        other.heightCm == heightCm &&
        other.age == age &&
        other.gender == gender &&
        other.notificationsOptIn == notificationsOptIn &&
        other.permissionGranted == permissionGranted &&
        other.pushToken == pushToken &&
        other.apnsToken == apnsToken;
  }

  @override
  int get hashCode => Object.hash(
        goal,
        level,
        weightKg,
        heightCm,
        age,
        gender,
        notificationsOptIn,
        permissionGranted,
        pushToken,
        apnsToken,
      );
}

enum RunGoal {
  startRunning('Bắt đầu chạy bộ'),
  loseWeight('Giảm cân'),
  buildEndurance('Tăng sức bền'),
  raceTraining('Luyện thi đấu'),
  stayActive('Giữ thói quen');

  const RunGoal(this.label);
  final String label;
}

enum RunLevel {
  beginner('Mới bắt đầu', 'Chưa từng chạy đều'),
  casual('Thỉnh thoảng', '1-2 lần / tuần'),
  regular('Đều đặn', '3-4 lần / tuần'),
  advanced('Nâng cao', '5+ lần / tuần');

  const RunLevel(this.label, this.subtitle);
  final String label;
  final String subtitle;
}

enum Gender { male, female, other }
