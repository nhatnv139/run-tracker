import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/data/models/chat_message.dart';
import 'package:runvie/features/ai_coach/presentation/widgets/training_plan_card.dart';

/// Render a single chat turn. The user side gets a coral gradient bubble
/// (right-aligned), the coach side gets a mint-tinted "glass" bubble on
/// the left.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.message,
    required this.onRate,
    required this.onApplyPlan,
    super.key,
  });

  final ChatMessage message;
  final void Function(int rating) onRate;
  final VoidCallback onApplyPlan;

  bool get _isUser => message.role == ChatRole.user;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final BorderRadius radius = BorderRadius.only(
      topLeft: const Radius.circular(AuroraSpacing.radiusXl),
      topRight: const Radius.circular(AuroraSpacing.radiusXl),
      bottomLeft: Radius.circular(_isUser ? AuroraSpacing.radiusXl : 4),
      bottomRight: Radius.circular(_isUser ? 4 : AuroraSpacing.radiusXl),
    );

    final BoxDecoration decoration = _isUser
        ? BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[
                AuroraColors.coralPrimary,
                AuroraColors.coralLight,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: radius,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AuroraColors.coralPrimary.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          )
        : BoxDecoration(
            color: (isDark
                    ? AuroraColors.mintDark
                    : AuroraColors.mintLight)
                .withOpacity(isDark ? 0.18 : 0.22),
            borderRadius: radius,
            border: Border.all(
              color: AuroraColors.mintSecondary.withOpacity(0.35),
              width: 1,
            ),
          );

    final Color textColor = _isUser
        ? Colors.white
        : (isDark
            ? AuroraColors.textPrimaryDark
            : AuroraColors.textPrimaryLight);

    return Align(
      alignment: _isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AuroraSpacing.lg,
            vertical: AuroraSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: _isUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AuroraSpacing.lg,
                  vertical: AuroraSpacing.md,
                ),
                decoration: decoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (message.status == ChatStatus.streaming &&
                        message.content.isEmpty)
                      const TypingDots()
                    else
                      SelectableText(
                        message.content,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: textColor,
                          height: 1.35,
                        ),
                      ),
                    if (message.planJson != null) ...<Widget>[
                      const SizedBox(height: AuroraSpacing.md),
                      TrainingPlanCard(
                        planJson: message.planJson!,
                        onApply: onApplyPlan,
                      ),
                    ],
                    if (message.status == ChatStatus.failed)
                      Padding(
                        padding: const EdgeInsets.only(top: AuroraSpacing.xs),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Icon(Icons.error_outline,
                                size: 14, color: AuroraColors.error),
                            const SizedBox(width: AuroraSpacing.xs),
                            Text(
                              'Gửi thất bại',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AuroraColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: AuroraSpacing.xs,
                  left: AuroraSpacing.xs,
                  right: AuroraSpacing.xs,
                ),
                child: Row(
                  mainAxisAlignment: _isUser
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _formatTimestamp(message.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? AuroraColors.textTertiaryDark
                            : AuroraColors.textTertiaryLight,
                      ),
                    ),
                    if (!_isUser && message.modelUsed != null) ...<Widget>[
                      const SizedBox(width: AuroraSpacing.sm),
                      _ModelBadge(model: message.modelUsed!),
                    ],
                    if (!_isUser &&
                        message.status == ChatStatus.sent &&
                        message.content.isNotEmpty) ...<Widget>[
                      const Spacer(),
                      _RatingButtons(
                        rating: message.rating ?? 0,
                        onRate: onRate,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime t) {
    final DateTime now = DateTime.now();
    final bool sameDay = now.year == t.year &&
        now.month == t.month &&
        now.day == t.day;
    if (sameDay) {
      return DateFormat.Hm().format(t);
    }
    return DateFormat('dd/MM HH:mm').format(t);
  }
}

class _ModelBadge extends StatelessWidget {
  const _ModelBadge({required this.model});
  final String model;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AuroraSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AuroraColors.lavenderTertiary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AuroraSpacing.radiusSm),
        border: Border.all(
          color: AuroraColors.lavenderTertiary.withOpacity(0.32),
        ),
      ),
      child: Text(
        model,
        style: theme.textTheme.labelSmall?.copyWith(
          color: AuroraColors.lavenderTertiary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RatingButtons extends StatelessWidget {
  const _RatingButtons({required this.rating, required this.onRate});

  final int rating;
  final void Function(int rating) onRate;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        InkResponse(
          radius: 18,
          onTap: () => onRate(rating == 1 ? 0 : 1),
          child: Padding(
            padding: const EdgeInsets.all(AuroraSpacing.xs),
            child: Icon(
              rating == 1 ? Icons.thumb_up : Icons.thumb_up_outlined,
              size: 16,
              color: rating == 1
                  ? AuroraColors.mintSecondary
                  : AuroraColors.textTertiaryLight,
            ),
          ),
        ),
        InkResponse(
          radius: 18,
          onTap: () => onRate(rating == -1 ? 0 : -1),
          child: Padding(
            padding: const EdgeInsets.all(AuroraSpacing.xs),
            child: Icon(
              rating == -1 ? Icons.thumb_down : Icons.thumb_down_outlined,
              size: 16,
              color: rating == -1
                  ? AuroraColors.error
                  : AuroraColors.textTertiaryLight,
            ),
          ),
        ),
      ],
    );
  }
}

/// Three pulsing dots — used inside the coach bubble while the SSE stream
/// has been opened but no token has arrived yet.
class TypingDots extends StatefulWidget {
  const TypingDots({super.key});

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      width: 36,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List<Widget>.generate(3, (int i) {
              final double t = (_controller.value + i * 0.2) % 1.0;
              final double scale = 0.6 + 0.4 * (1 - (t - 0.5).abs() * 2).clamp(0, 1);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Transform.scale(
                  scale: scale,
                  child: const _Dot(),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AuroraColors.mintSecondary,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
