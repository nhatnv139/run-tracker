import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/data/models/chat_message.dart';
import 'package:runvie/features/ai_coach/presentation/widgets/conversation_starters.dart';
import 'package:runvie/features/ai_coach/presentation/widgets/message_bubble.dart';
import 'package:runvie/features/ai_coach/presentation/widgets/quick_replies.dart';
import 'package:runvie/features/ai_coach/providers/ai_coach_providers.dart';

class AiCoachScreen extends ConsumerStatefulWidget {
  const AiCoachScreen({super.key});

  @override
  ConsumerState<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends ConsumerState<AiCoachScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _showFab = false;
  Timer? _rateLimitTicker;
  int _rateLimitRemaining = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_handleScroll);
    _input.dispose();
    _scroll.dispose();
    _rateLimitTicker?.cancel();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scroll.hasClients) return;
    final double distanceFromBottom =
        _scroll.position.maxScrollExtent - _scroll.position.pixels;
    final bool show = distanceFromBottom > 240;
    if (show != _showFab) {
      setState(() => _showFab = show);
    }
  }

  void _scrollToBottom({bool animate = true}) {
    if (!_scroll.hasClients) return;
    final double target = _scroll.position.maxScrollExtent;
    if (animate) {
      _scroll.animateTo(
        target,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    } else {
      _scroll.jumpTo(target);
    }
  }

  Future<void> _send([String? override]) async {
    final String text = (override ?? _input.text).trim();
    if (text.isEmpty) return;
    _input.clear();
    FocusScope.of(context).unfocus();
    await ref
        .read(chatControllerProvider.notifier)
        .sendMessage(text);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToBottom());
  }

  void _startRateLimitTicker(DateTime until) {
    _rateLimitTicker?.cancel();
    _rateLimitRemaining = until.difference(DateTime.now()).inSeconds;
    if (_rateLimitRemaining <= 0) return;
    _rateLimitTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _rateLimitRemaining--;
        if (_rateLimitRemaining <= 0) {
          _rateLimitTicker?.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ChatState state = ref.watch(chatControllerProvider);
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    // React to rate-limited transitions.
    ref.listen<ChatState>(chatControllerProvider, (ChatState? prev, ChatState next) {
      if (next.rateLimitedUntil != null &&
          prev?.rateLimitedUntil != next.rateLimitedUntil) {
        _startRateLimitTicker(next.rateLimitedUntil!);
      }
      if (next.messages.length != (prev?.messages.length ?? 0)) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    final bool empty = state.messages.isEmpty;
    final bool rateLimited = _rateLimitRemaining > 0;

    return Scaffold(
      backgroundColor: isDark
          ? AuroraColors.bgDark
          : AuroraColors.bgLight,
      appBar: AppBar(
        title: const Text('Coach AI'),
        elevation: 0,
        actions: <Widget>[
          if (!empty)
            IconButton(
              tooltip: 'Xoá lịch sử',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => _confirmClear(context),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            if (state.costCapped) _CostCapBanner(onUpgrade: _navigateToPaywall),
            if (rateLimited)
              _RateLimitBanner(remainingSeconds: _rateLimitRemaining),
            Expanded(
              child: Stack(
                children: <Widget>[
                  empty && state.hasLoadedHistory
                      ? ConversationStarters(
                          starters: ChatController.conversationStarters,
                          onTap: (ConversationStarter s) => _send(s.prompt),
                        )
                      : ListView.builder(
                          controller: _scroll,
                          padding: const EdgeInsets.only(
                            top: AuroraSpacing.md,
                            bottom: AuroraSpacing.xl,
                          ),
                          itemCount: state.messages.length,
                          itemBuilder: (BuildContext context, int i) {
                            final ChatMessage m = state.messages[i];
                            return MessageBubble(
                              message: m,
                              onRate: (int r) => ref
                                  .read(chatControllerProvider.notifier)
                                  .rateMessage(m.id, r),
                              onApplyPlan: () => _applyPlan(context, m),
                            );
                          },
                        ),
                  if (_showFab)
                    Positioned(
                      bottom: AuroraSpacing.lg,
                      right: AuroraSpacing.lg,
                      child: FloatingActionButton.small(
                        backgroundColor: AuroraColors.coralPrimary,
                        foregroundColor: Colors.white,
                        onPressed: () => _scrollToBottom(),
                        child: const Icon(Icons.arrow_downward),
                      ),
                    ),
                ],
              ),
            ),
            if (!empty)
              QuickReplies(
                replies: ref.watch(quickRepliesProvider),
                onTap: (QuickReply r) => _send(r.text),
              ),
            _ChatInput(
              controller: _input,
              isStreaming: state.isStreaming,
              disabled: rateLimited || state.costCapped,
              onSend: () => _send(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Xoá lịch sử chat?'),
        content: const Text(
            'Toàn bộ tin nhắn sẽ bị xoá khỏi thiết bị này. Không thể hoàn tác.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(chatControllerProvider.notifier).clearHistory();
    }
  }

  void _applyPlan(BuildContext context, ChatMessage message) {
    // Hand-off to the plan feature — we only emit a SnackBar here so we do
    // not need to depend on the plan controller from this folder.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã ghi nhận giáo án. Mở tab Lịch tập để xem.'),
      ),
    );
  }

  void _navigateToPaywall() {
    // Owned-folder boundary: we do not import paywall directly. The parent
    // feature can listen for `state.costCapped` if it wants to navigate.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nâng cấp Premium để chat không giới hạn.'),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  const _ChatInput({
    required this.controller,
    required this.isStreaming,
    required this.disabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isStreaming;
  final bool disabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AuroraColors.surfaceDark
            : AuroraColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AuroraColors.surfaceDarkAlt
                : AuroraColors.surfaceLightAlt,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AuroraSpacing.lg,
        AuroraSpacing.sm,
        AuroraSpacing.sm,
        AuroraSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !disabled,
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: disabled
                    ? 'Tạm dừng — vui lòng chờ'
                    : 'Hỏi Coach AI điều gì đó...',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AuroraSpacing.radiusLg),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark
                    ? AuroraColors.surfaceDarkAlt
                    : AuroraColors.surfaceLightAlt,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AuroraSpacing.lg,
                  vertical: AuroraSpacing.md,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: AuroraSpacing.sm),
          Material(
            color: disabled
                ? AuroraColors.coralPrimary.withOpacity(0.32)
                : AuroraColors.coralPrimary,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: disabled ? null : onSend,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: isStreaming
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CostCapBanner extends StatelessWidget {
  const _CostCapBanner({required this.onUpgrade});
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AuroraColors.lavenderTertiary,
      child: InkWell(
        onTap: onUpgrade,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AuroraSpacing.lg,
            vertical: AuroraSpacing.md,
          ),
          child: Row(
            children: const <Widget>[
              Icon(Icons.workspace_premium, color: Colors.white),
              SizedBox(width: AuroraSpacing.sm),
              Expanded(
                child: Text(
                  'Bạn đã đạt giới hạn miễn phí. Nhấn để nâng cấp Premium.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _RateLimitBanner extends StatelessWidget {
  const _RateLimitBanner({required this.remainingSeconds});
  final int remainingSeconds;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AuroraColors.warning.withOpacity(0.15),
      padding: const EdgeInsets.symmetric(
        horizontal: AuroraSpacing.lg,
        vertical: AuroraSpacing.sm,
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.timer, color: AuroraColors.warning, size: 18),
          const SizedBox(width: AuroraSpacing.sm),
          Expanded(
            child: Text(
              'Hệ thống quá tải. Thử lại sau $remainingSeconds giây.',
              style: const TextStyle(color: AuroraColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}
