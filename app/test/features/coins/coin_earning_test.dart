import 'package:flutter_test/flutter_test.dart';

import 'package:runvie/data/repositories/coin_repository.dart';

void main() {
  group('CoinEarnCalculator.rateForLevel', () {
    const CoinEarnCalculator calc = CoinEarnCalculator();
    test('level 1 starts at base rate', () {
      expect(calc.rateForLevel(1), 10);
    });
    test('decays 1 coin per 10 levels', () {
      expect(calc.rateForLevel(10), 9);
      expect(calc.rateForLevel(30), 7);
      expect(calc.rateForLevel(50), 5);
    });
    test('floors at minCoinPerKm', () {
      expect(calc.rateForLevel(100), 5);
      expect(calc.rateForLevel(1000), 5);
    });
  });

  group('CoinEarnCalculator.earningsForRun', () {
    const CoinEarnCalculator calc = CoinEarnCalculator();

    test('linear km x rate', () {
      expect(
        calc.earningsForRun(distanceKm: 3, level: 1, earnedTodaySoFar: 0),
        30,
      );
    });

    test('respects daily cap', () {
      expect(
        calc.earningsForRun(distanceKm: 10, level: 1, earnedTodaySoFar: 0),
        50,
      );
      expect(
        calc.earningsForRun(distanceKm: 5, level: 1, earnedTodaySoFar: 45),
        5,
      );
      expect(
        calc.earningsForRun(distanceKm: 5, level: 1, earnedTodaySoFar: 50),
        0,
      );
    });

    test('applies decay for higher levels', () {
      // Level 30 = 7 coin/km
      expect(
        calc.earningsForRun(distanceKm: 4, level: 30, earnedTodaySoFar: 0),
        28,
      );
    });

    test('zero or negative distance returns 0', () {
      expect(
        calc.earningsForRun(distanceKm: 0, level: 1, earnedTodaySoFar: 0),
        0,
      );
      expect(
        calc.earningsForRun(distanceKm: -1, level: 1, earnedTodaySoFar: 0),
        0,
      );
    });

    test('partial km floor', () {
      // 2.7km * 10 = 27 coin (floor)
      expect(
        calc.earningsForRun(distanceKm: 2.7, level: 1, earnedTodaySoFar: 0),
        27,
      );
    });
  });
}
