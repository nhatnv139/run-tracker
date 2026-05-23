import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:runvie/features/settings/models/app_settings.dart';

void main() {
  group('AppSettings', () {
    test('defaults are sane', () {
      const AppSettings s = AppSettings();
      expect(s.themeMode, ThemeMode.system);
      expect(s.voiceCoachEnabled, isTrue);
      expect(s.voiceGender, VoiceGender.bac);
      expect(s.unit, DistanceUnit.km);
      expect(s.dailyStepGoal, 8000);
      expect(s.dailyKmGoal, 5.0);
      expect(s.languageCode, 'vi');
    });

    test('JSON round-trip', () {
      const AppSettings original = AppSettings(
        themeMode: ThemeMode.dark,
        voiceCoachEnabled: false,
        voiceGender: VoiceGender.nam,
        unit: DistanceUnit.mi,
        pushEnabled: false,
        reminderEnabled: true,
        reminderHour: 6,
        reminderMinute: 15,
        cloudBackup: false,
        dailyStepGoal: 12000,
        dailyKmGoal: 7.5,
        languageCode: 'en',
      );
      final AppSettings back = AppSettings.fromJson(original.toJson());
      expect(back.themeMode, ThemeMode.dark);
      expect(back.voiceCoachEnabled, isFalse);
      expect(back.voiceGender, VoiceGender.nam);
      expect(back.unit, DistanceUnit.mi);
      expect(back.pushEnabled, isFalse);
      expect(back.reminderHour, 6);
      expect(back.reminderMinute, 15);
      expect(back.cloudBackup, isFalse);
      expect(back.dailyStepGoal, 12000);
      expect(back.dailyKmGoal, 7.5);
      expect(back.languageCode, 'en');
    });

    test('copyWith mutates only specified fields', () {
      const AppSettings s = AppSettings();
      final AppSettings d = s.copyWith(themeMode: ThemeMode.dark);
      expect(d.themeMode, ThemeMode.dark);
      expect(d.voiceCoachEnabled, s.voiceCoachEnabled);
      expect(d.voiceGender, s.voiceGender);
    });

    test('unknown enum values fall back to defaults', () {
      final AppSettings s = AppSettings.fromJson(<String, dynamic>{
        'themeMode': 'foobar',
        'voiceGender': 'middle',
        'unit': 'parsec',
      });
      expect(s.themeMode, ThemeMode.system);
      expect(s.voiceGender, VoiceGender.bac);
      expect(s.unit, DistanceUnit.km);
    });
  });
}
