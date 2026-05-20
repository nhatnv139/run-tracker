import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DataClassName('RunRow')
class Runs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  RealColumn get distanceMeters =>
      real().withDefault(const Constant<double>(0))();
  IntColumn get durationSec => integer().withDefault(const Constant<int>(0))();
  IntColumn get movingTimeSec =>
      integer().withDefault(const Constant<int>(0))();
  RealColumn get avgPaceSecPerKm =>
      real().withDefault(const Constant<double>(0))();
  RealColumn get calories => real().withDefault(const Constant<double>(0))();
  RealColumn get elevationGainM =>
      real().withDefault(const Constant<double>(0))();
  TextColumn get encodedPolyline => text().nullable()();
  IntColumn get rpe => integer().nullable()();
  TextColumn get terrain =>
      text().withDefault(const Constant<String>('road'))();
  TextColumn get status =>
      text().withDefault(const Constant<String>('ongoing'))();
  TextColumn get note => text().nullable()();
}

@DataClassName('TrackPointRow')
class TrackPoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get runId =>
      integer().references(Runs, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get timestamp => dateTime()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get accuracy => real()();
  RealColumn get altitude => real().nullable()();
  RealColumn get speed => real().nullable()();
  IntColumn get sequence => integer().withDefault(const Constant<int>(0))();
  BoolColumn get isPaused => boolean().withDefault(const Constant<bool>(false))();
}

@DataClassName('SplitRow')
class ActivitySplits extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get runId =>
      integer().references(Runs, #id, onDelete: KeyAction.cascade)();
  IntColumn get kmIndex => integer()();
  IntColumn get durationSec => integer()();
  RealColumn get paceSecPerKm => real()();
  RealColumn get hrAvg => real().nullable()();
  RealColumn get elevationGainM =>
      real().withDefault(const Constant<double>(0))();
  DateTimeColumn get completedAt => dateTime()();
}

/// Daily aggregated pedometer rollup. Composite PK on (date, source) so
/// two devices/sources for the same user/day can co-exist; the
/// repository dedupes when reading the user-facing total.
@DataClassName('DailyStepRow')
class DailyStepsTable extends Table {
  @override
  String get tableName => 'daily_steps';

  DateTimeColumn get date => dateTime()();
  TextColumn get source =>
      text().withDefault(const Constant<String>('pedometer'))();
  IntColumn get steps => integer().withDefault(const Constant<int>(0))();
  RealColumn get distanceMeters =>
      real().withDefault(const Constant<double>(0))();
  RealColumn get calories => real().withDefault(const Constant<double>(0))();
  IntColumn get activeMinutes =>
      integer().withDefault(const Constant<int>(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{date, source};
}

@DriftDatabase(
  tables: <Type>[Runs, TrackPoints, ActivitySplits, DailyStepsTable],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) => m.createAll(),
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            // Extend runs with new columns + create new tables.
            await m.addColumn(runs, runs.movingTimeSec);
            await m.addColumn(runs, runs.elevationGainM);
            await m.addColumn(runs, runs.encodedPolyline);
            await m.addColumn(runs, runs.rpe);
            await m.addColumn(runs, runs.terrain);
            await m.addColumn(runs, runs.status);
            await m.addColumn(trackPoints, trackPoints.sequence);
            await m.addColumn(trackPoints, trackPoints.isPaused);
            await m.createTable(activitySplits);
          }
          if (from < 3) {
            await m.createTable(dailyStepsTable);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File(p.join(dir.path, 'runvie.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
