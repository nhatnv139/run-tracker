import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:runvie/features/settings/models/app_settings.dart';

class SettingsRepository {
  SettingsRepository();

  static const String _key = 'app_settings_v1';

  final StreamController<AppSettings> _controller =
      StreamController<AppSettings>.broadcast();

  AppSettings? _cached;

  Future<AppSettings> load() async {
    if (_cached != null) return _cached!;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      _cached = const AppSettings();
      return _cached!;
    }
    try {
      final Map<String, dynamic> json =
          jsonDecode(raw) as Map<String, dynamic>;
      _cached = AppSettings.fromJson(json);
    } catch (_) {
      _cached = const AppSettings();
    }
    return _cached!;
  }

  Future<AppSettings> save(AppSettings settings) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(settings.toJson()));
    _cached = settings;
    _controller.add(settings);
    return settings;
  }

  Stream<AppSettings> watch() => _controller.stream;

  void dispose() => _controller.close();
}
