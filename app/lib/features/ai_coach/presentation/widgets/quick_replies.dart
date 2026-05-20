import 'package:flutter/material.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/data/models/chat_message.dart';

/// Horizontal strip of suggestion chips shown above the input field.
class QuickReplies extends StatelessWidget {
  const QuickReplies({
    required this.replies,
    required this.onTap,
    super.key,
  });

  final List<QuickReply> replies;
  final void Function(QuickReply reply) onTap;

  @override
  Widget build(BuildContext context) {
    if (replies.isEmpty) return const SizedBox.shrink();
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AuroraSpacing.lg,
          vertical: AuroraSpacing.xs,
        ),
        itemBuilder: (BuildContext context, int i) {
          final QuickReply reply = replies[i];
          return ActionChip(
            label: Text(reply.label),
            labelStyle: theme.textTheme.labelLarge?.copyWith(
              color: AuroraColors.coralPrimary,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor:
                AuroraColors.coralPrimary.withOpacity(isDark ? 0.18 : 0.10),
            side: BorderSide(
              color: AuroraColors.coralPrimary.withOpacity(0.32),
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AuroraSpacing.radiusPill),
            ),
            onPressed: () => onTap(reply),
          );
        },
        separatorBuilder: (_, __) =>
            const SizedBox(width: AuroraSpacing.sm),
        itemCount: replies.length,
      ),
    );
  }
}
