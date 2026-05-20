import 'package:flutter/foundation.dart';

/// Role of a chat message turn.
enum ChatRole { user, coach, system }

/// Status of an outgoing message (for offline / retry UX).
enum ChatStatus { sending, streaming, sent, failed, queued }

/// A single chat turn — persisted to local Drift and rendered in the
/// chat UI. Designed to be safe to use cross-isolate (`@immutable`).
///
/// Implemented as a hand-rolled Freezed-style class (copyWith + equality)
/// so we don't need to run build_runner in this PR. Public surface
/// matches what a Freezed class would expose.
@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.status = ChatStatus.sent,
    this.modelUsed,
    this.costUsd,
    this.tokensInput,
    this.tokensOutput,
    this.rating,
    this.planJson,
  });

  final String id;
  final ChatRole role;
  final String content;
  final DateTime createdAt;
  final ChatStatus status;
  final String? modelUsed;
  final double? costUsd;
  final int? tokensInput;
  final int? tokensOutput;

  /// -1 = thumbs down, 0 = unrated, 1 = thumbs up.
  final int? rating;

  /// If the coach returned a `training_plan` JSON object, the raw map
  /// is stored here so the UI can render an inline action card.
  final Map<String, dynamic>? planJson;

  ChatMessage copyWith({
    String? id,
    ChatRole? role,
    String? content,
    DateTime? createdAt,
    ChatStatus? status,
    String? modelUsed,
    double? costUsd,
    int? tokensInput,
    int? tokensOutput,
    int? rating,
    Map<String, dynamic>? planJson,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      modelUsed: modelUsed ?? this.modelUsed,
      costUsd: costUsd ?? this.costUsd,
      tokensInput: tokensInput ?? this.tokensInput,
      tokensOutput: tokensOutput ?? this.tokensOutput,
      rating: rating ?? this.rating,
      planJson: planJson ?? this.planJson,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'role': role.name,
        'content': content,
        'created_at': createdAt.toIso8601String(),
        'status': status.name,
        'model_used': modelUsed,
        'cost_usd': costUsd,
        'tokens_input': tokensInput,
        'tokens_output': tokensOutput,
        'rating': rating,
        'plan_json': planJson,
      };

  static ChatMessage fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'] as String,
        role: ChatRole.values.firstWhere(
          (ChatRole r) => r.name == j['role'],
          orElse: () => ChatRole.user,
        ),
        content: j['content'] as String? ?? '',
        createdAt: DateTime.parse(j['created_at'] as String),
        status: ChatStatus.values.firstWhere(
          (ChatStatus s) => s.name == (j['status'] as String? ?? 'sent'),
          orElse: () => ChatStatus.sent,
        ),
        modelUsed: j['model_used'] as String?,
        costUsd: (j['cost_usd'] as num?)?.toDouble(),
        tokensInput: j['tokens_input'] as int?,
        tokensOutput: j['tokens_output'] as int?,
        rating: j['rating'] as int?,
        planJson: j['plan_json'] as Map<String, dynamic>?,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChatMessage &&
            other.id == id &&
            other.role == role &&
            other.content == content &&
            other.createdAt == createdAt &&
            other.status == status &&
            other.modelUsed == modelUsed &&
            other.costUsd == costUsd &&
            other.tokensInput == tokensInput &&
            other.tokensOutput == tokensOutput &&
            other.rating == rating);
  }

  @override
  int get hashCode => Object.hash(
        id,
        role,
        content,
        createdAt,
        status,
        modelUsed,
        costUsd,
        tokensInput,
        tokensOutput,
        rating,
      );
}

/// Quick-reply chip definition.
@immutable
class QuickReply {
  const QuickReply({required this.label, required this.text});
  final String label;
  final String text;
}

/// Conversation starter card for first-run.
@immutable
class ConversationStarter {
  const ConversationStarter({
    required this.title,
    required this.prompt,
    required this.icon,
  });
  final String title;
  final String prompt;
  final String icon; // Material icon name as string
}
