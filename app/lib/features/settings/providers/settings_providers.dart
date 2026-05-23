import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runvie/features/settings/data/settings_repository.dart';
import 'package:runvie/features/settings/models/app_settings.dart';

final Provider<SettingsRepository> settingsRepositoryProvider =
    Provider<SettingsRepository>((Ref ref) {
  final SettingsRepository repo = SettingsRepository();
  ref.onDispose(repo.dispose);
  return repo;
});

class AppSettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    return ref.read(settingsRepositoryProvider).load();
  }

  Future<void> _mutate(AppSettings Function(AppSettings) update) async {
    final AppSettings current =
        state.valueOrNull ?? const AppSettings();
    final AppSettings next = update(current);
    state = AsyncData<AppSettings>(next);
    await ref.read(settingsRepositoryProvider).save(next);
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _mutate((AppSettings s) => s.copyWith(themeMode: mode));

  Future<void> setVoiceCoachEnabled(bool enabled) =>
      _mutate((AppSettings s) => s.copyWith(voiceCoachEnabled: enabled));

  Future<void> setVoiceGender(VoiceGender g) =>
      _mutate((AppSettings s) => s.copyWith(voiceGender: g));

  Future<void> setUnit(DistanceUnit u) =>
      _mutate((AppSettings s) => s.copyWith(unit: u));

  Future<void> setPushEnabled(bool enabled) =>
      _mutate((AppSettings s) => s.copyWith(pushEnabled: enabled));

  Future<void> setReminderEnabled(bool enabled) =>
      _mutate((AppSettings s) => s.copyWith(reminderEnabled: enabled));

  Future<void> setReminderTime(int hour, int minute) =>
      _mutate((AppSettings s) =>
          s.copyWith(reminderHour: hour, reminderMinute: minute));

  Future<void> setCloudBackup(bool enabled) =>
      _mutate((AppSettings s) => s.copyWith(cloudBackup: enabled));

  Future<void> setDailyStepGoal(int goal) =>
      _mutate((AppSettings s) => s.copyWith(dailyStepGoal: goal));

  Future<void> setDailyKmGoal(double goal) =>
      _mutate((AppSettings s) => s.copyWith(dailyKmGoal: goal));
}

final AsyncNotifierProvider<AppSettingsNotifier, AppSettings>
    appSettingsProvider =
    AsyncNotifierProvider<AppSettingsNotifier, AppSettings>(
        AppSettingsNotifier.new);
