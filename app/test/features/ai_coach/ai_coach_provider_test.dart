import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:runvie/data/models/chat_message.dart';
import 'package:runvie/data/repositories/chat_repository.dart';
import 'package:runvie/features/ai_coach/providers/ai_coach_providers.dart';
import 'package:runvie/services/ai_coach_client.dart';

void main() {
  group('ChatController', () {
    late InMemoryChatRepository repo;
    late ProviderContainer container;
    late _FakeAiCoachClient fakeClient;

    setUp(() {
      repo = InMemoryChatRepository();
      fakeClient = _FakeAiCoachClient();
      container = ProviderContainer(overrides: <Override>[
        chatRepositoryProvider.overrideWithValue(repo),
        aiCoachClientProvider.overrideWithValue(fakeClient),
      ]);
      // Prime the notifier so build() runs.
      container.read(chatControllerProvider);
    });

    tearDown(() => container.dispose());

    test('sendMessage transitions: idle -> streaming -> done', () async {
      fakeClient.scriptedChunks = <ChatStreamChunk>[
        const ChatStreamChunk(kind: 'delta', delta: 'Chào '),
        const ChatStreamChunk(kind: 'delta', delta: 'bạn'),
        const ChatStreamChunk(
          kind: 'done',
          model: 'gpt-4o-mini',
          costUsd: 0.001,
          tokensInput: 100,
          tokensOutput: 25,
        ),
      ];

      final List<bool> streamingStates = <bool>[];
      container.listen<ChatState>(chatControllerProvider,
          (ChatState? prev, ChatState next) {
        streamingStates.add(next.isStreaming);
      });

      await container
          .read(chatControllerProvider.notifier)
          .sendMessage('Xin chào');

      final ChatState state = container.read(chatControllerProvider);
      expect(state.isStreaming, isFalse);
      expect(state.messages.length, 2);
      expect(state.messages.first.role, ChatRole.user);
      expect(state.messages.first.content, 'Xin chào');
      expect(state.messages.last.role, ChatRole.coach);
      expect(state.messages.last.content, 'Chào bạn');
      expect(state.messages.last.modelUsed, 'gpt-4o-mini');
      expect(state.messages.last.tokensOutput, 25);
      // We must have observed at least one streaming=true intermediate.
      expect(streamingStates.contains(true), isTrue);
    });

    test('rate-limit error sets countdown state and marks coach failed',
        () async {
      fakeClient.errorToThrow = const AiCoachRateLimited(45);

      await container
          .read(chatControllerProvider.notifier)
          .sendMessage('Test');

      final ChatState state = container.read(chatControllerProvider);
      expect(state.rateLimitedUntil, isNotNull);
      expect(state.isStreaming, isFalse);
      expect(state.messages.last.status, ChatStatus.failed);
      expect(state.messages.last.content, contains('45'));
    });

    test('cost-cap error flips costCapped flag', () async {
      fakeClient.errorToThrow = const AiCoachCostCap();
      await container
          .read(chatControllerProvider.notifier)
          .sendMessage('Test');
      final ChatState state = container.read(chatControllerProvider);
      expect(state.costCapped, isTrue);
    });

    test('rateMessage persists and updates state', () async {
      fakeClient.scriptedChunks = <ChatStreamChunk>[
        const ChatStreamChunk(kind: 'delta', delta: 'ok'),
        const ChatStreamChunk(kind: 'done'),
      ];
      await container
          .read(chatControllerProvider.notifier)
          .sendMessage('Hi');
      final String coachId =
          container.read(chatControllerProvider).messages.last.id;

      await container
          .read(chatControllerProvider.notifier)
          .rateMessage(coachId, 1);

      final ChatState state = container.read(chatControllerProvider);
      expect(state.messages.last.rating, 1);
      final List<ChatMessage> stored = await repo.loadHistory();
      expect(stored.firstWhere((ChatMessage m) => m.id == coachId).rating, 1);
    });

    test('clearHistory empties messages and underlying repo', () async {
      fakeClient.scriptedChunks = <ChatStreamChunk>[
        const ChatStreamChunk(kind: 'delta', delta: 'x'),
        const ChatStreamChunk(kind: 'done'),
      ];
      await container
          .read(chatControllerProvider.notifier)
          .sendMessage('Hi');
      expect(container.read(chatControllerProvider).messages, isNotEmpty);

      await container.read(chatControllerProvider.notifier).clearHistory();
      expect(container.read(chatControllerProvider).messages, isEmpty);
      expect(await repo.loadHistory(), isEmpty);
    });

    test('plan event attaches planJson to final coach message', () async {
      fakeClient.scriptedChunks = <ChatStreamChunk>[
        const ChatStreamChunk(kind: 'delta', delta: 'Đây là giáo án.'),
        const ChatStreamChunk(
          kind: 'plan',
          planJson: <String, dynamic>{
            'title': 'Sub-50 10K',
            'weeks': 12,
          },
        ),
        const ChatStreamChunk(kind: 'done'),
      ];
      await container
          .read(chatControllerProvider.notifier)
          .sendMessage('lập giáo án');
      final ChatMessage coach =
          container.read(chatControllerProvider).messages.last;
      expect(coach.planJson, isNotNull);
      expect(coach.planJson!['title'], 'Sub-50 10K');
    });
  });

  group('AiCoachClient SSE parsing', () {
    test('parses delta + done + plan events', () async {
      final AiCoachClient client = AiCoachClient();
      final List<int> bytes = _utf8(
        'event: delta\n'
        'data: {"text": "Chào "}\n'
        '\n'
        'event: delta\n'
        'data: {"text": "bạn"}\n'
        '\n'
        'event: plan\n'
        'data: {"title": "T1"}\n'
        '\n'
        'event: done\n'
        'data: {"model": "m", "cost_usd": 0.01, "tokens_input": 1, '
        '"tokens_output": 2}\n'
        '\n',
      );
      final Stream<List<int>> raw = Stream<List<int>>.value(bytes);

      final List<ChatStreamChunk> chunks =
          await client.parseRawStream(raw).toList();

      expect(chunks.map((ChatStreamChunk c) => c.kind),
          <String>['delta', 'delta', 'plan', 'done']);
      expect(chunks[0].delta, 'Chào ');
      expect(chunks[1].delta, 'bạn');
      expect(chunks[2].planJson?['title'], 'T1');
      expect(chunks[3].model, 'm');
      expect(chunks[3].costUsd, 0.01);
    });
  });
}

List<int> _utf8(String s) => utf8.encode(s);

/// Test double — bypasses HTTP and emits a scripted SSE chunk list.
class _FakeAiCoachClient extends AiCoachClient {
  _FakeAiCoachClient() : super(baseUrl: 'http://test.local');

  List<ChatStreamChunk> scriptedChunks = <ChatStreamChunk>[];
  AiCoachException? errorToThrow;
  final List<({String id, int rating})> ratings = <({String id, int rating})>[];

  @override
  Stream<ChatStreamChunk> chatStream({
    required String message,
    required List<ChatMessage> history,
    Map<String, dynamic>? userProfile,
    CancelToken? cancelToken,
  }) async* {
    if (errorToThrow != null) throw errorToThrow!;
    for (final ChatStreamChunk c in scriptedChunks) {
      await Future<void>.delayed(Duration.zero);
      yield c;
    }
  }

  @override
  Future<void> rate({required String messageId, required int rating}) async {
    ratings.add((id: messageId, rating: rating));
  }
}
