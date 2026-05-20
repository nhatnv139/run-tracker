import 'package:flutter_test/flutter_test.dart';

import 'package:runvie/data/models/chat_message.dart';
import 'package:runvie/data/repositories/chat_repository.dart';

void main() {
  group('InMemoryChatRepository', () {
    late ChatRepository repo;

    setUp(() {
      repo = InMemoryChatRepository();
    });

    test('save then loadHistory returns messages in chronological order',
        () async {
      final ChatMessage older = _msg('a', 'hello',
          role: ChatRole.user, at: DateTime(2025, 1, 1, 10));
      final ChatMessage newer = _msg('b', 'hi there',
          role: ChatRole.coach, at: DateTime(2025, 1, 1, 11));
      await repo.save(newer);
      await repo.save(older);

      final List<ChatMessage> history = await repo.loadHistory();
      expect(history.map((ChatMessage m) => m.id), <String>['a', 'b']);
    });

    test('updateRating only changes rating', () async {
      final ChatMessage m = _msg('x', 'tip', role: ChatRole.coach);
      await repo.save(m);
      await repo.updateRating('x', 1);
      final List<ChatMessage> loaded = await repo.loadHistory();
      expect(loaded.single.rating, 1);
      expect(loaded.single.content, 'tip');
    });

    test('clear removes everything', () async {
      await repo.save(_msg('a', 'hi'));
      await repo.save(_msg('b', 'bye'));
      await repo.clear();
      expect((await repo.loadHistory()), isEmpty);
    });

    test('pendingQueue returns queued + failed messages only', () async {
      await repo.save(_msg('a', 'sent', status: ChatStatus.sent));
      await repo.save(_msg('b', 'queued', status: ChatStatus.queued));
      await repo.save(_msg('c', 'failed', status: ChatStatus.failed));
      final List<ChatMessage> pending = await repo.pendingQueue();
      expect(pending.map((ChatMessage m) => m.id).toSet(),
          <String>{'b', 'c'});
    });

    test('markSent flips status', () async {
      await repo.save(_msg('a', 'q', status: ChatStatus.queued));
      await repo.markSent('a');
      expect((await repo.loadHistory()).single.status, ChatStatus.sent);
    });

    test('saveAll bulk-inserts', () async {
      await repo.saveAll(<ChatMessage>[
        _msg('a', 'one'),
        _msg('b', 'two'),
        _msg('c', 'three'),
      ]);
      expect((await repo.loadHistory()).length, 3);
    });

    test('save is idempotent on same id (last-write wins)', () async {
      await repo.save(_msg('a', 'first'));
      await repo.save(_msg('a', 'second'));
      final List<ChatMessage> all = await repo.loadHistory();
      expect(all.length, 1);
      expect(all.single.content, 'second');
    });
  });
}

ChatMessage _msg(
  String id,
  String content, {
  ChatRole role = ChatRole.user,
  ChatStatus status = ChatStatus.sent,
  DateTime? at,
}) {
  return ChatMessage(
    id: id,
    role: role,
    content: content,
    createdAt: at ?? DateTime.now(),
    status: status,
  );
}
