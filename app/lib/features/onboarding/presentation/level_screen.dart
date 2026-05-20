import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runvie/core/router/routes.dart';
import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/features/onboarding/models/onboarding_state.dart';
import 'package:runvie/features/onboarding/presentation/_onboarding_layout.dart';
import 'package:runvie/features/onboarding/providers/onboarding_provider.dart';
import 'package:runvie/shared/widgets/aurora_button.dart';

class LevelScreen extends ConsumerWidget {
  const LevelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState s = ref.watch(onboardingControllerProvider);
    final OnboardingController ctrl =
        ref.read(onboardingControllerProvider.notifier);

    return OnboardingLayout(
      step: 3,
      title: 'Trình độ hiện tại?',
      subtitle: 'Đừng lo, ai cũng bắt đầu từ đâu đó.',
      primary: AuroraButton(
        label: 'Tiếp tục',
        variant: AuroraButtonVariant.gradient,
        onPressed: s.level == null
            ? null
            : () => context.push(AppRoutes.onboardingPersonalize),
      ),
      child: ListView.separated(
        itemCount: RunLevel.values.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AuroraSpacing.md),
        itemBuilder: (BuildContext ctx, int i) {
          final RunLevel l = RunLevel.values[i];
          final bool selected = s.level == l;
          return Material(
            color: selected
                ? AuroraColors.mintSecondary.withValues(alpha: 0.10)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AuroraSpacing.radiusLg),
            child: InkWell(
              borderRadius: BorderRadius.circular(AuroraSpacing.radiusLg),
              onTap: () => ctrl.setLevel(l),
              child: Container(
                padding: const EdgeInsets.all(AuroraSpacing.lg),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AuroraSpacing.radiusLg),
                  border: Border.all(
                    color: selected
                        ? AuroraColors.mintSecondary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(l.label,
                              style:
                                  Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 2),
                          Text(l.subtitle,
                              style:
                                  Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    if (selected)
                      const Icon(Icons.check_circle_rounded,
                          color: AuroraColors.mintSecondary),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
