import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runvie/data/models/chat_message.dart';

/// Public interface for AI-Coach chat persistence.
///
/// The production implementation is [DriftChatRepository] in
/// `chat_repository_drift.dart`, which uses a self-contained
/// `runvie_chat.sqlite` database (kept separate from `AppDatabase` so the
/// AI Coach feature does not need to mutate the shared schema).
///
/// Tests inject [InMemoryChatRepository]; the default provider here also
/// returns the in-memory variant so the app keeps linking before
/// `build_runner` has been run.
abstract class ChatRepository {
  Future<List<ChatMessage>> loadHistory({int limit = 200});
  Future<void> save(ChatMessage message);
  Future<void> saveAll(List<ChatMessage> messages);
  Future<void> updateRating(String id, int rating);
  Future<void> clear();

  /// Queue of messages that failed to send while offline.
  Future<List<ChatMessage>> pendingQueue();
  Future<void> markSent(String id);
  Future<void> markFailed(String id);
}

/// In-memory implementation used by tests and as a safe default before
/// the Drift code-gen has been executed.
class InMemoryChatRepository implements ChatRepository {
  InMemoryChatRepository();

  final Map<String, ChatMessage> _store = <String, ChatMessage>{};

  @override
  Future<List<ChatMessage>> loadHistory({int limit = 200}) async {
    final List<ChatMessage> all = _store.values.toList()
      ..sort((ChatMessage a, ChatMessage b) =>
          a.createdAt.compareTo(b.createdAt));
    return all.take(limit).toList(growable: false);
  }

  @override
  Future<void> save(ChatMessage message) async {
    _store[message.id] = message;
  }

  @override
  Future<void> saveAll(List<ChatMessage> messages) async {
    for (final ChatMessage m in messages) {
      _store[m.id] = m;
    }
  }

  @override
  Future<void> updateRating(String id, int rating) async {
    final ChatMessage? existing = _store[id];
    if (existing != null) _store[id] = existing.copyWith(rating: rating);
  }

  @override
  Future<void> clear() async {
    _store.clear();
  }

  @override
  Future<List<ChatMessage>> pendingQueue() async {
    final List<ChatMessage> q = _store.values
        .where((ChatMessage m) =>
            m.status == ChatStatus.queued || m.status == ChatStatus.failed)
        .toList();
    q.sort((ChatMessage a, ChatMessage b) =>
        a.createdAt.compareTo(b.createdAt));
    return q;
  }

  @override
  Future<void> markSent(String id) async {
    final ChatMessage? existing = _store[id];
    if (existing != null) {
      _store[id] = existing.copyWith(status: ChatStatus.sent);
    }
  }

  @override
  Future<void> markFailed(String id) async {
    final ChatMessage? existing = _store[id];
    if (existing != null) {
      _store[id] = existing.copyWith(status: ChatStatus.failed);
    }
  }
}

/// Default provider — in-memory. `main.dart` (or a feature-level override)
/// should swap this for the Drift-backed repository once `build_runner`
/// has produced the `*.g.dart` file.
final Provider<ChatRepository> chatRepositoryProvider =
    Provider<ChatRepository>((Ref ref) {
  return InMemoryChatRepository();
});
