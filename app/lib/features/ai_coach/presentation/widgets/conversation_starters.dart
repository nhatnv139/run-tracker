import 'package:flutter/material.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/data/models/chat_message.dart';

/// Five large suggestion cards shown when the chat history is empty (first
/// run / after clearHistory).
class ConversationStarters extends StatelessWidget {
  const ConversationStarters({
    required this.starters,
    required this.onTap,
    super.key,
  });

  final List<ConversationStarter> starters;
  final void Function(ConversationStarter starter) onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AuroraSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              top: AuroraSpacing.xxl,
              bottom: AuroraSpacing.lg,
            ),
            child: Column(
              children: <Widget>[
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AuroraColors.auroraLinear,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: AuroraSpacing.md),
                Text(
                  'Coach AI của RunVie',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AuroraSpacing.xs),
                Text(
                  'Tôi giúp bạn lập giáo án, phân tích buổi chạy và trả lời mọi câu hỏi liên quan.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AuroraColors.textSecondaryDark
                        : AuroraColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          ...starters.map((ConversationStarter s) => Padding(
                padding: const EdgeInsets.only(bottom: AuroraSpacing.sm),
                child: _StarterCard(
                  starter: s,
                  onTap: () => onTap(s),
                ),
              )),
        ],
      ),
    );
  }
}

class _StarterCard extends StatelessWidget {
  const _StarterCard({required this.starter, required this.onTap});

  final ConversationStarter starter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark
          ? AuroraColors.surfaceDarkAlt
          : AuroraColors.surfaceLightAlt,
      borderRadius: BorderRadius.circular(AuroraSpacing.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AuroraSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AuroraSpacing.lg),
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AuroraColors.coralPrimary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AuroraSpacing.radiusMd),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _iconFor(starter.icon),
                  color: AuroraColors.coralPrimary,
                ),
              ),
              const SizedBox(width: AuroraSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      starter.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      starter.prompt,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AuroraColors.textSecondaryDark
                            : AuroraColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: isDark
                    ? AuroraColors.textTertiaryDark
                    : AuroraColors.textTertiaryLight,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'event_note':
        return Icons.event_note;
      case 'insights':
        return Icons.insights;
      case 'restaurant':
        return Icons.restaurant;
      case 'favorite':
        return Icons.favorite;
      case 'healing':
        return Icons.healing;
      default:
        return Icons.chat_bubble_outline;
    }
  }
}
