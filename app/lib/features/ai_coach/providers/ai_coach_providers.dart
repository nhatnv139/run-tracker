import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:runvie/data/models/chat_message.dart';
import 'package:runvie/data/repositories/chat_repository.dart';
import 'package:runvie/services/ai_coach_client.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

@immutable
class ChatState {
  const ChatState({
    this.messages = const <ChatMessage>[],
    this.isStreaming = false,
    this.error,
    this.rateLimitedUntil,
    this.costCapped = false,
    this.hasLoadedHistory = false,
  });

  final List<ChatMessage> messages;
  final bool isStreaming;
  final String? error;
  final DateTime? rateLimitedUntil;
  final bool costCapped;
  final bool hasLoadedHistory;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isStreaming,
    Object? error = _sentinel,
    Object? rateLimitedUntil = _sentinel,
    bool? costCapped,
    bool? hasLoadedHistory,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      error: identical(error, _sentinel) ? this.error : error as String?,
      rateLimitedUntil: identical(rateLimitedUntil, _sentinel)
          ? this.rateLimitedUntil
          : rateLimitedUntil as DateTime?,
      costCapped: costCapped ?? this.costCapped,
      hasLoadedHistory: hasLoadedHistory ?? this.hasLoadedHistory,
    );
  }

  static const Object _sentinel = Object();
}

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

class ChatController extends Notifier<ChatState> {
  static const Uuid _uuid = Uuid();

  /// Conversation starters shown on first-run.
  static const List<ConversationStarter> conversationStarters =
      <ConversationStarter>[
    ConversationStarter(
      title: 'Lập giáo án',
      prompt: 'Giúp tôi lập giáo án sub-50 cho 10K trong 12 tuần.',
      icon: 'event_note',
    ),
    ConversationStarter(
      title: 'Phân tích buổi chạy',
      prompt: 'Phân tích buổi chạy gần nhất của tôi và gợi ý cải thiện.',
      icon: 'insights',
    ),
    ConversationStarter(
      title: 'Dinh dưỡng trước long run',
      prompt: 'Tôi nên ăn gì trước long run cuối tuần?',
      icon: 'restaurant',
    ),
    ConversationStarter(
      title: 'Vùng nhịp tim Z2',
      prompt: 'HR Z2 của tôi là bao nhiêu? Cách tính như thế nào?',
      icon: 'favorite',
    ),
    ConversationStarter(
      title: 'Phục hồi đầu gối',
      prompt: 'Đầu gối hơi đau sau bài tempo - tôi nên phục hồi ra sao?',
      icon: 'healing',
    ),
  ];

  /// Quick replies offered after every coach turn.
  static const List<QuickReply> defaultQuickReplies = <QuickReply>[
    QuickReply(
      label: 'Dinh dưỡng long run',
      text: 'Tôi nên ăn gì trước long run?',
    ),
    QuickReply(
      label: 'Giáo án sub-50 10K',
      text: 'Hãy lập giáo án sub-50 10K cho tôi.',
    ),
    QuickReply(
      label: 'HR Z2 là bao nhiêu?',
      text: 'HR Z2 là bao nhiêu? Cách tính ra sao?',
    ),
  ];

  late final ChatRepository _repo;
  late final AiCoachClient _client;
  StreamSubscription<ChatStreamChunk>? _activeSub;

  @override
  ChatState build() {
    _repo = ref.read(chatRepositoryProvider);
    _client = ref.read(aiCoachClientProvider);
    ref.onDispose(() {
      _activeSub?.cancel();
    });
    Future<void>.microtask(_loadHistory);
    return const ChatState();
  }

  Future<void> _loadHistory() async {
    try {
      final List<ChatMessage> history = await _repo.loadHistory();
      if (!ref.mounted) return;
      state = state.copyWith(
        messages: history,
        hasLoadedHistory: true,
      );
    } catch (e) {
      state = state.copyWith(
        hasLoadedHistory: true,
        error: 'Không tải được lịch sử.',
      );
    }
  }

  Future<void> sendMessage(
    String text, {
    Map<String, dynamic>? userProfile,
  }) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // Hard guards.
    final DateTime? blockedUntil = state.rateLimitedUntil;
    if (blockedUntil != null && blockedUntil.isAfter(DateTime.now())) {
      return;
    }
    if (state.costCapped) return;

    final ChatMessage userMsg = ChatMessage(
      id: _uuid.v4(),
      role: ChatRole.user,
      content: trimmed,
      createdAt: DateTime.now(),
      status: ChatStatus.sent,
    );

    final ChatMessage coachStub = ChatMessage(
      id: _uuid.v4(),
      role: ChatRole.coach,
      content: '',
      createdAt: DateTime.now(),
      status: ChatStatus.streaming,
    );

    state = state.copyWith(
      messages: <ChatMessage>[...state.messages, userMsg, coachStub],
      isStreaming: true,
      error: null,
    );

    await _repo.save(userMsg);

    final List<ChatMessage> historyForCall = state.messages
        .where((ChatMessage m) => m.id != coachStub.id && m.content.isNotEmpty)
        .toList();

    try {
      final StringBuffer buffer = StringBuffer();
      Map<String, dynamic>? planJson;
      String? model;
      double? cost;
      int? tokensIn;
      int? tokensOut;

      final Stream<ChatStreamChunk> stream = _client.chatStream(
        message: trimmed,
        history: historyForCall,
        userProfile: userProfile,
      );

      await for (final ChatStreamChunk chunk in stream) {
        switch (chunk.kind) {
          case 'delta':
            if (chunk.delta != null) buffer.write(chunk.delta);
            _updateStreaming(coachStub.id, buffer.toString());
            break;
          case 'plan':
            planJson = chunk.planJson;
            break;
          case 'done':
            if (chunk.fullText != null && chunk.fullText!.isNotEmpty) {
              buffer
                ..clear()
                ..write(chunk.fullText);
            }
            model = chunk.model;
            cost = chunk.costUsd;
            tokensIn = chunk.tokensInput;
            tokensOut = chunk.tokensOutput;
            break;
          case 'error':
            throw AiCoachServerError(0, chunk.error ?? 'stream error');
        }
      }

      final ChatMessage finalCoach = coachStub.copyWith(
        content: buffer.toString(),
        status: ChatStatus.sent,
        modelUsed: model,
        costUsd: cost,
        tokensInput: tokensIn,
        tokensOutput: tokensOut,
        planJson: planJson,
      );
      _replaceMessage(finalCoach);
      await _repo.save(finalCoach);
      state = state.copyWith(isStreaming: false);
    } on AiCoachOffline {
      _markCoachFailed(coachStub.id, 'Bạn đang offline. Tin nhắn đã lưu vào hàng chờ.');
      await _repo.save(userMsg.copyWith(status: ChatStatus.queued));
    } on AiCoachRateLimited catch (e) {
      final DateTime until =
          DateTime.now().add(Duration(seconds: e.retryAfterSeconds));
      state = state.copyWith(rateLimitedUntil: until, isStreaming: false);
      _markCoachFailed(coachStub.id,
          'Quá tải, vui lòng thử lại sau ${e.retryAfterSeconds} giây.');
    } on AiCoachCostCap {
      state = state.copyWith(costCapped: true, isStreaming: false);
      _markCoachFailed(coachStub.id,
          'Bạn đã đạt giới hạn miễn phí hôm nay. Nâng cấp Premium để chat không giới hạn.');
    } on AiCoachException catch (e) {
      _markCoachFailed(coachStub.id, 'Có lỗi: ${e.message}');
    } catch (e) {
      _markCoachFailed(coachStub.id, 'Lỗi không xác định.');
    }
  }

  void _updateStreaming(String coachId, String content) {
    final List<ChatMessage> updated = state.messages
        .map((ChatMessage m) =>
            m.id == coachId ? m.copyWith(content: content) : m)
        .toList(growable: false);
    state = state.copyWith(messages: updated);
  }

  void _replaceMessage(ChatMessage replacement) {
    final List<ChatMessage> updated = state.messages
        .map((ChatMessage m) => m.id == replacement.id ? replacement : m)
        .toList(growable: false);
    state = state.copyWith(messages: updated);
  }

  void _markCoachFailed(String coachId, String reason) {
    final List<ChatMessage> updated = state.messages
        .map((ChatMessage m) => m.id == coachId
            ? m.copyWith(content: reason, status: ChatStatus.failed)
            : m)
        .toList(growable: false);
    state =
        state.copyWith(messages: updated, isStreaming: false, error: reason);
  }

  Future<void> rateMessage(String id, int rating) async {
    final List<ChatMessage> updated = state.messages
        .map((ChatMessage m) => m.id == id ? m.copyWith(rating: rating) : m)
        .toList(growable: false);
    state = state.copyWith(messages: updated);
    await _repo.updateRating(id, rating);
    try {
      await _client.rate(messageId: id, rating: rating);
    } catch (_) {
      // best-effort
    }
  }

  Future<void> clearHistory() async {
    state = state.copyWith(messages: const <ChatMessage>[]);
    await _repo.clear();
  }

  /// Re-attempt the offline queue. Returns the number of messages
  /// successfully resent.
  Future<int> flushQueue({
    Map<String, dynamic>? userProfile,
  }) async {
    final List<ChatMessage> queue = await _repo.pendingQueue();
    int sent = 0;
    for (final ChatMessage queued in queue) {
      if (queued.role != ChatRole.user) continue;
      await sendMessage(queued.content, userProfile: userProfile);
      await _repo.markSent(queued.id);
      sent++;
    }
    return sent;
  }
}

final NotifierProvider<ChatController, ChatState> chatControllerProvider =
    NotifierProvider<ChatController, ChatState>(ChatController.new);

/// Convenience: quick replies surface — currently static; the backend can
/// later return contextual replies in the SSE `done` event.
final Provider<List<QuickReply>> quickRepliesProvider =
    Provider<List<QuickReply>>((Ref ref) {
  return ChatController.defaultQuickReplies;
});
