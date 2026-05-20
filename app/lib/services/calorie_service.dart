import 'package:runvie/features/onboarding/models/onboarding_state.dart';

/// Calorie estimation using Mifflin-St Jeor (BMR) + MET tables.
class CalorieService {
  CalorieService._();
  static final CalorieService instance = CalorieService._();

  /// Mifflin-St Jeor RMR (kcal/day).
  double restingMetabolicRate({
    required double weightKg,
    required double heightCm,
    required int ageYears,
    required Gender gender,
  }) {
    final double base = 10 * weightKg + 6.25 * heightCm - 5 * ageYears;
    switch (gender) {
      case Gender.male:
        return base + 5;
      case Gender.female:
        return base - 161;
      case Gender.other:
        return base - 78; // midpoint
    }
  }

  /// MET value for running, derived from pace (min/km).
  /// Reference: 2011 Compendium of Physical Activities.
  double metForRunningPace(Duration pacePerKm) {
    if (pacePerKm == Duration.zero) return 0;
    final double minPerKm = pacePerKm.inSeconds / 60.0;
    if (minPerKm >= 9) return 6.0;   // ~6.7 km/h - light jog
    if (minPerKm >= 7.5) return 8.3;  // ~8.0 km/h
    if (minPerKm >= 6.5) return 9.8;  // ~9.2 km/h
    if (minPerKm >= 5.5) return 11.0; // ~10.8 km/h
    if (minPerKm >= 4.5) return 12.8; // ~13.3 km/h
    if (minPerKm >= 4.0) return 14.5; // ~15 km/h
    return 16.0; // sub-4'/km
  }

  /// Total calories for a session.
  /// kcal = MET * weight(kg) * hours.
  double caloriesForSession({
    required double weightKg,
    required Duration pacePerKm,
    required Duration elapsed,
  }) {
    final double met = metForRunningPace(pacePerKm);
    final double hours = elapsed.inSeconds / 3600.0;
    return met * weightKg * hours;
  }
}
