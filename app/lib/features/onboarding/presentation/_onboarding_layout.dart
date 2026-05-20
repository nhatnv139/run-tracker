import 'package:flutter/material.dart';

import 'package:runvie/core/theme/spacing.dart';

/// Shared scaffold for onboarding screens.
class OnboardingLayout extends StatelessWidget {
  const OnboardingLayout({
    required this.step,
    required this.title,
    required this.child,
    this.subtitle,
    this.primary,
    this.secondary,
    super.key,
  });

  final int step; // 1..7
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? primary;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AuroraSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: AuroraSpacing.lg),
              _ProgressDots(current: step),
              const SizedBox(height: AuroraSpacing.xxl),
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: AuroraSpacing.sm),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                ),
              ],
              const SizedBox(height: AuroraSpacing.xl),
              Expanded(child: child),
              if (secondary != null) ...<Widget>[
                secondary!,
                const SizedBox(height: AuroraSpacing.sm),
              ],
              if (primary != null) primary!,
              const SizedBox(height: AuroraSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.current});
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(7, (int i) {
        final bool active = i < current;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 4,
            decoration: BoxDecoration(
              color: active
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
