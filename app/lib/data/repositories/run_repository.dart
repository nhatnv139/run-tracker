import 'package:runvie/data/local/app_database.dart';

/// Local-first run repository. Sync to Supabase happens via remote/.
class RunRepository {
  RunRepository(this._db);
  final AppDatabase _db;

  Future<int> createRun({required DateTime startedAt}) {
    return _db.into(_db.runs).insert(
          RunsCompanion.insert(startedAt: startedAt),
        );
  }

  Future<void> finishRun({
    required int id,
    required DateTime endedAt,
    required double distanceMeters,
    required int durationSec,
    required double avgPaceSecPerKm,
    required double calories,
  }) {
    return (_db.update(_db.runs)..where(($RunsTable r) => r.id.equals(id)))
        .write(RunsCompanion(
      endedAt: Value<DateTime>(endedAt),
      distanceMeters: Value<double>(distanceMeters),
      durationSec: Value<int>(durationSec),
      avgPaceSecPerKm: Value<double>(avgPaceSecPerKm),
      calories: Value<double>(calories),
    ));
  }

  Future<List<RunRow>> recent({int limit = 20}) {
    return (_db.select(_db.runs)
          ..orderBy(<OrderClauseGenerator<$RunsTable>>[
            ($RunsTable r) =>
                OrderingTerm(expression: r.startedAt, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .get();
  }
}
