import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runvie/data/models/chat_message.dart';
import 'package:runvie/services/ai_coach_client.dart';

/// Parameters for a single SSE chat-stream request. Kept as a value type
/// so the `StreamProvider.family` cache keys cleanly.
@immutable
class ChatStreamRequest {
  const ChatStreamRequest({
    required this.message,
    this.history = const <ChatMessage>[],
    this.userProfile,
  });

  final String message;
  final List<ChatMessage> history;
  final Map<String, dynamic>? userProfile;

  @override
  bool operator ==(Object other) =>
      other is ChatStreamRequest &&
      other.message == message &&
      other.userProfile == userProfile &&
      _listEquals(other.history, history);

  @override
  int get hashCode => Object.hash(message, history.length, userProfile);

  static bool _listEquals(List<ChatMessage> a, List<ChatMessage> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Live SSE token stream. Each emitted value is one parsed chunk; the UI
/// is expected to assemble deltas into a final message.
final AutoDisposeStreamProviderFamily<ChatStreamChunk, ChatStreamRequest>
    sseStreamProvider =
    StreamProvider.autoDispose.family<ChatStreamChunk, ChatStreamRequest>(
  (AutoDisposeStreamProviderRef<ChatStreamChunk> ref,
      ChatStreamRequest request) {
    final AiCoachClient client = ref.watch(aiCoachClientProvider);
    return client.chatStream(
      message: request.message,
      history: request.history,
      userProfile: request.userProfile,
    );
  },
);
