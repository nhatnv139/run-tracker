import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:runvie/data/models/chat_message.dart';
import 'package:runvie/data/repositories/chat_repository.dart';

part 'chat_database.g.dart';

/// Drift table for persisted AI Coach chat messages. Lives in a separate
/// SQLite file (`runvie_chat.sqlite`) so this feature does not depend on
/// a schema migration of the shared [AppDatabase].
@DataClassName('ChatMessageRow')
class ChatMessages extends Table {
  TextColumn get id => text()();
  TextColumn get role => text()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get status =>
      text().withDefault(const Constant<String>('sent'))();
  TextColumn get modelUsed => text().nullable()();
  RealColumn get costUsd => real().nullable()();
  IntColumn get tokensInput => integer().nullable()();
  IntColumn get tokensOutput => integer().nullable()();
  IntColumn get rating => integer().nullable()();
  TextColumn get planJson => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DriftDatabase(tables: <Type>[ChatMessages])
class ChatDatabase extends _$ChatDatabase {
  ChatDatabase() : super(_openConnection());

  /// Used by tests with `NativeDatabase.memory()`.
  ChatDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) => m.createAll(),
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File(p.join(dir.path, 'runvie_chat.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

/// Drift-backed [ChatRepository]. Only compiles after `flutter pub run
/// build_runner build` has produced `chat_database.g.dart`.
class DriftChatRepository implements ChatRepository {
  DriftChatRepository(this._db);
  final ChatDatabase _db;

  @override
  Future<List<ChatMessage>> loadHistory({int limit = 200}) async {
    final List<ChatMessageRow> rows = await (_db.select(_db.chatMessages)
          ..orderBy(<OrderClauseGenerator<$ChatMessagesTable>>[
            ($ChatMessagesTable t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
          ])
          ..limit(limit))
        .get();
    return rows.map(_rowToModel).toList(growable: false);
  }

  @override
  Future<void> save(ChatMessage message) async {
    await _db
        .into(_db.chatMessages)
        .insertOnConflictUpdate(_modelToCompanion(message));
  }

  @override
  Future<void> saveAll(List<ChatMessage> messages) async {
    await _db.batch((Batch b) {
      for (final ChatMessage m in messages) {
        b.insert(
          _db.chatMessages,
          _modelToCompanion(m),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  @override
  Future<void> updateRating(String id, int rating) async {
    await (_db.update(_db.chatMessages)
          ..where(($ChatMessagesTable t) => t.id.equals(id)))
        .write(ChatMessagesCompanion(rating: Value<int?>(rating)));
  }

  @override
  Future<void> clear() async {
    await _db.delete(_db.chatMessages).go();
  }

  @override
  Future<List<ChatMessage>> pendingQueue() async {
    final List<ChatMessageRow> rows = await (_db.select(_db.chatMessages)
          ..where(($ChatMessagesTable t) =>
              t.status.equals(ChatStatus.queued.name) |
              t.status.equals(ChatStatus.failed.name))
          ..orderBy(<OrderClauseGenerator<$ChatMessagesTable>>[
            ($ChatMessagesTable t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
          ]))
        .get();
    return rows.map(_rowToModel).toList(growable: false);
  }

  @override
  Future<void> markSent(String id) async {
    await (_db.update(_db.chatMessages)
          ..where(($ChatMessagesTable t) => t.id.equals(id)))
        .write(
            ChatMessagesCompanion(status: Value<String>(ChatStatus.sent.name)));
  }

  @override
  Future<void> markFailed(String id) async {
    await (_db.update(_db.chatMessages)
          ..where(($ChatMessagesTable t) => t.id.equals(id)))
        .write(ChatMessagesCompanion(
            status: Value<String>(ChatStatus.failed.name)));
  }

  ChatMessage _rowToModel(ChatMessageRow r) {
    Map<String, dynamic>? plan;
    final String? raw = r.planJson;
    if (raw != null && raw.isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) plan = decoded;
      } catch (_) {
        plan = null;
      }
    }
    return ChatMessage(
      id: r.id,
      role: ChatRole.values.firstWhere(
        (ChatRole role) => role.name == r.role,
        orElse: () => ChatRole.user,
      ),
      content: r.content,
      createdAt: r.createdAt,
      status: ChatStatus.values.firstWhere(
        (ChatStatus s) => s.name == r.status,
        orElse: () => ChatStatus.sent,
      ),
      modelUsed: r.modelUsed,
      costUsd: r.costUsd,
      tokensInput: r.tokensInput,
      tokensOutput: r.tokensOutput,
      rating: r.rating,
      planJson: plan,
    );
  }

  ChatMessagesCompanion _modelToCompanion(ChatMessage m) {
    return ChatMessagesCompanion(
      id: Value<String>(m.id),
      role: Value<String>(m.role.name),
      content: Value<String>(m.content),
      createdAt: Value<DateTime>(m.createdAt),
      status: Value<String>(m.status.name),
      modelUsed: Value<String?>(m.modelUsed),
      costUsd: Value<double?>(m.costUsd),
      tokensInput: Value<int?>(m.tokensInput),
      tokensOutput: Value<int?>(m.tokensOutput),
      rating: Value<int?>(m.rating),
      planJson: Value<String?>(
        m.planJson == null ? null : jsonEncode(m.planJson),
      ),
    );
  }
}
