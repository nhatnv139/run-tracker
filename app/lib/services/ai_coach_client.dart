import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runvie/data/models/chat_message.dart';

/// Exception family for AI Coach API errors. Keeps the UI layer free of
/// `DioException` imports.
@immutable
sealed class AiCoachException implements Exception {
  const AiCoachException(this.message);
  final String message;

  @override
  String toString() => 'AiCoachException($message)';
}

class AiCoachOffline extends AiCoachException {
  const AiCoachOffline() : super('offline');
}

class AiCoachRateLimited extends AiCoachException {
  const AiCoachRateLimited(this.retryAfterSeconds)
      : super('rate_limited');
  final int retryAfterSeconds;
}

class AiCoachCostCap extends AiCoachException {
  const AiCoachCostCap() : super('cost_cap_exceeded');
}

class AiCoachServerError extends AiCoachException {
  const AiCoachServerError(this.statusCode, super.message);
  final int statusCode;
}

/// One token chunk parsed from the SSE stream.
@immutable
class ChatStreamChunk {
  const ChatStreamChunk({
    required this.kind,
    this.delta,
    this.fullText,
    this.model,
    this.costUsd,
    this.tokensInput,
    this.tokensOutput,
    this.planJson,
    this.error,
  });

  /// `delta` => partial token; `done` => final metadata; `plan` => training
  /// plan attachment; `error` => terminal error.
  final String kind;
  final String? delta;
  final String? fullText;
  final String? model;
  final double? costUsd;
  final int? tokensInput;
  final int? tokensOutput;
  final Map<String, dynamic>? planJson;
  final String? error;
}

/// Thin wrapper around dio that exposes a Server-Sent-Events stream from
/// the FastAPI `/v1/chat/stream` endpoint.
///
/// Wire-format expected from the backend (one event per line, blank line
/// between events):
/// ```
/// event: delta
/// data: {"text": "Chào "}
///
/// event: delta
/// data: {"text": "bạn"}
///
/// event: plan
/// data: { ...training_plan json... }
///
/// event: done
/// data: {"model": "gpt-4o-mini", "cost_usd": 0.0012,
///         "tokens_input": 421, "tokens_output": 88}
/// ```
class AiCoachClient {
  AiCoachClient({
    Dio? dio,
    this.baseUrl = 'https://api.runvie.app',
    this.authTokenProvider,
  }) : _dio = dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 8))) {
    _dio.options.baseUrl = baseUrl;
  }

  final Dio _dio;
  final String baseUrl;
  final Future<String?> Function()? authTokenProvider;

  /// Public for tests.
  @visibleForTesting
  Dio get dio => _dio;

  /// POST `/v1/chat/stream` and emit parsed SSE events. The caller is
  /// responsible for assembling the deltas into a final message.
  Stream<ChatStreamChunk> chatStream({
    required String message,
    required List<ChatMessage> history,
    Map<String, dynamic>? userProfile,
    CancelToken? cancelToken,
  }) async* {
    final List<Map<String, dynamic>> historyJson = history
        .where((ChatMessage m) =>
            m.role != ChatRole.system && m.content.trim().isNotEmpty)
        .map((ChatMessage m) => <String, dynamic>{
              'role': m.role == ChatRole.user ? 'user' : 'assistant',
              'content': m.content,
            })
        .toList(growable: false);

    final String? token =
        authTokenProvider == null ? null : await authTokenProvider!.call();

    final Map<String, String> headers = <String, String>{
      'Accept': 'text/event-stream',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    Response<ResponseBody> response;
    try {
      response = await _dio.post<ResponseBody>(
        '/v1/chat/stream',
        data: <String, dynamic>{
          'message': message,
          'history': historyJson,
          if (userProfile != null) 'profile': userProfile,
        },
        options: Options(
          headers: headers,
          responseType: ResponseType.stream,
        ),
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }

    final ResponseBody? body = response.data;
    if (body == null) {
      throw const AiCoachServerError(500, 'empty response body');
    }
    final int status = response.statusCode ?? 200;
    if (status >= 400) {
      throw _statusToException(status, response.headers.value('retry-after'));
    }

    yield* _parseEventStream(body.stream);
  }

  /// Visible for unit tests — re-uses the SSE parser on an arbitrary byte
  /// stream so we do not need a real HTTP server.
  @visibleForTesting
  Stream<ChatStreamChunk> parseRawStream(Stream<List<int>> raw) =>
      _parseEventStream(raw);

  Stream<ChatStreamChunk> _parseEventStream(Stream<List<int>> raw) async* {
    final Stream<String> lines = raw
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    String currentEvent = 'message';
    final StringBuffer dataBuffer = StringBuffer();

    Future<ChatStreamChunk?> flush() async {
      if (dataBuffer.isEmpty && currentEvent == 'message') {
        return null;
      }
      final String raw = dataBuffer.toString();
      dataBuffer.clear();
      final String event = currentEvent;
      currentEvent = 'message';
      return _decodeEvent(event, raw);
    }

    await for (final String line in lines) {
      if (line.isEmpty) {
        final ChatStreamChunk? chunk = await flush();
        if (chunk != null) yield chunk;
        continue;
      }
      if (line.startsWith(':')) {
        // SSE comment / heartbeat — ignore.
        continue;
      }
      if (line.startsWith('event:')) {
        currentEvent = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        if (dataBuffer.isNotEmpty) dataBuffer.write('\n');
        dataBuffer.write(line.substring(5).trimLeft());
      }
    }
    final ChatStreamChunk? tail = await flush();
    if (tail != null) yield tail;
  }

  ChatStreamChunk? _decodeEvent(String event, String raw) {
    if (raw.isEmpty) return null;
    Map<String, dynamic>? data;
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) data = decoded;
    } catch (_) {
      // Treat as plain text delta.
      return ChatStreamChunk(kind: 'delta', delta: raw);
    }

    switch (event) {
      case 'delta':
      case 'message':
        return ChatStreamChunk(
          kind: 'delta',
          delta: data?['text'] as String? ?? data?['delta'] as String? ?? '',
        );
      case 'done':
        return ChatStreamChunk(
          kind: 'done',
          fullText: data?['text'] as String?,
          model: data?['model'] as String?,
          costUsd: (data?['cost_usd'] as num?)?.toDouble(),
          tokensInput: (data?['tokens_input'] as num?)?.toInt(),
          tokensOutput: (data?['tokens_output'] as num?)?.toInt(),
        );
      case 'plan':
        return ChatStreamChunk(kind: 'plan', planJson: data);
      case 'error':
        return ChatStreamChunk(
          kind: 'error',
          error: data?['message'] as String? ?? 'unknown error',
        );
      default:
        return ChatStreamChunk(kind: event, delta: raw);
    }
  }

  AiCoachException _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      return const AiCoachOffline();
    }
    final int code = e.response?.statusCode ?? 0;
    final String? retryAfter = e.response?.headers.value('retry-after');
    if (code != 0) return _statusToException(code, retryAfter);
    return AiCoachServerError(code, e.message ?? 'unknown');
  }

  AiCoachException _statusToException(int status, String? retryAfter) {
    if (status == 429) {
      final int secs = int.tryParse(retryAfter ?? '') ?? 30;
      return AiCoachRateLimited(secs);
    }
    if (status == 402) return const AiCoachCostCap();
    return AiCoachServerError(status, 'http $status');
  }

  /// Submit a thumbs up / down rating for a previous coach turn.
  Future<void> rate({
    required String messageId,
    required int rating,
  }) async {
    try {
      await _dio.post<dynamic>(
        '/v1/chat/feedback',
        data: <String, dynamic>{'message_id': messageId, 'rating': rating},
      );
    } on DioException catch (e) {
      // Non-fatal — just bubble a tagged exception so callers can log.
      throw _mapDioError(e);
    }
  }
}

final Provider<AiCoachClient> aiCoachClientProvider =
    Provider<AiCoachClient>((Ref ref) {
  return AiCoachClient();
});
