import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum DistanceUnit { km, mi }

enum VoiceGender { bac, nam }

@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.voiceCoachEnabled = true,
    this.voiceGender = VoiceGender.bac,
    this.unit = DistanceUnit.km,
    this.pushEnabled = true,
    this.reminderEnabled = true,
    this.reminderHour = 18,
    this.reminderMinute = 30,
    this.cloudBackup = true,
    this.dailyStepGoal = 8000,
    this.dailyKmGoal = 5.0,
    this.languageCode = 'vi',
  });

  final ThemeMode themeMode;
  final bool voiceCoachEnabled;
  final VoiceGender voiceGender;
  final DistanceUnit unit;
  final bool pushEnabled;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final bool cloudBackup;
  final int dailyStepGoal;
  final double dailyKmGoal;
  final String languageCode;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? voiceCoachEnabled,
    VoiceGender? voiceGender,
    DistanceUnit? unit,
    bool? pushEnabled,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool? cloudBackup,
    int? dailyStepGoal,
    double? dailyKmGoal,
    String? languageCode,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      voiceCoachEnabled: voiceCoachEnabled ?? this.voiceCoachEnabled,
      voiceGender: voiceGender ?? this.voiceGender,
      unit: unit ?? this.unit,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      cloudBackup: cloudBackup ?? this.cloudBackup,
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
      dailyKmGoal: dailyKmGoal ?? this.dailyKmGoal,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'themeMode': themeMode.name,
        'voiceCoachEnabled': voiceCoachEnabled,
        'voiceGender': voiceGender.name,
        'unit': unit.name,
        'pushEnabled': pushEnabled,
        'reminderEnabled': reminderEnabled,
        'reminderHour': reminderHour,
        'reminderMinute': reminderMinute,
        'cloudBackup': cloudBackup,
        'dailyStepGoal': dailyStepGoal,
        'dailyKmGoal': dailyKmGoal,
        'languageCode': languageCode,
      };

  factory AppSettings.fromJson(Map<String, dynamic> j) => AppSettings(
        themeMode: ThemeMode.values.firstWhere(
          (ThemeMode m) => m.name == j['themeMode'],
          orElse: () => ThemeMode.system,
        ),
        voiceCoachEnabled: j['voiceCoachEnabled'] as bool? ?? true,
        voiceGender: VoiceGender.values.firstWhere(
          (VoiceGender g) => g.name == j['voiceGender'],
          orElse: () => VoiceGender.bac,
        ),
        unit: DistanceUnit.values.firstWhere(
          (DistanceUnit u) => u.name == j['unit'],
          orElse: () => DistanceUnit.km,
        ),
        pushEnabled: j['pushEnabled'] as bool? ?? true,
        reminderEnabled: j['reminderEnabled'] as bool? ?? true,
        reminderHour: (j['reminderHour'] as num?)?.toInt() ?? 18,
        reminderMinute: (j['reminderMinute'] as num?)?.toInt() ?? 30,
        cloudBackup: j['cloudBackup'] as bool? ?? true,
        dailyStepGoal: (j['dailyStepGoal'] as num?)?.toInt() ?? 8000,
        dailyKmGoal: (j['dailyKmGoal'] as num?)?.toDouble() ?? 5.0,
        languageCode: j['languageCode'] as String? ?? 'vi',
      );
}
