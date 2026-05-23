import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:runvie/features/plan/models/active_plan.dart';

class PlanRepository {
  PlanRepository();

  static const String _key = 'active_plan_v1';

  ActivePlan? _cached;
  final StreamController<ActivePlan?> _controller =
      StreamController<ActivePlan?>.broadcast();

  Future<ActivePlan?> load() async {
    if (_cached != null) return _cached;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      _cached = ActivePlan.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      _cached = null;
    }
    return _cached;
  }

  Future<ActivePlan> startPlan(String templateId, {DateTime? startDate}) async {
    final ActivePlan plan = ActivePlan(
      templateId: templateId,
      startDate: startDate ?? DateTime.now(),
    );
    await _save(plan);
    return plan;
  }

  Future<ActivePlan> markDone(int week, int day) async {
    final ActivePlan? current = await load();
    if (current == null) {
      throw StateError('No active plan');
    }
    final Set<String> next = Set<String>.from(current.completedWorkouts);
    next.add(ActivePlan.workoutKey(week, day));
    final ActivePlan updated = current.copyWith(completedWorkouts: next);
    await _save(updated);
    return updated;
  }

  Future<ActivePlan> unmarkDone(int week, int day) async {
    final ActivePlan? current = await load();
    if (current == null) {
      throw StateError('No active plan');
    }
    final Set<String> next = Set<String>.from(current.completedWorkouts);
    next.remove(ActivePlan.workoutKey(week, day));
    final ActivePlan updated = current.copyWith(completedWorkouts: next);
    await _save(updated);
    return updated;
  }

  Future<void> cancel() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    _cached = null;
    _controller.add(null);
  }

  Future<void> _save(ActivePlan plan) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(plan.toJson()));
    _cached = plan;
    _controller.add(plan);
  }

  Stream<ActivePlan?> watch() => _controller.stream;

  void dispose() => _controller.close();
}
