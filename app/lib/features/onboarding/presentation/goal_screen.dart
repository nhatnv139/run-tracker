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

class GoalScreen extends ConsumerWidget {
  const GoalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState s = ref.watch(onboardingControllerProvider);
    final OnboardingController ctrl =
        ref.read(onboardingControllerProvider.notifier);

    return OnboardingLayout(
      step: 2,
      title: 'Mục tiêu của bạn?',
      subtitle: 'Chúng tôi sẽ thiết kế trải nghiệm phù hợp.',
      primary: AuroraButton(
        label: 'Tiếp tục',
        variant: AuroraButtonVariant.gradient,
        onPressed: s.goal == null
            ? null
            : () => context.push(AppRoutes.onboardingLevel),
      ),
      child: ListView.separated(
        itemCount: RunGoal.values.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AuroraSpacing.md),
        itemBuilder: (BuildContext ctx, int i) {
          final RunGoal g = RunGoal.values[i];
          final bool selected = s.goal == g;
          return Material(
            color: selected
                ? AuroraColors.coralPrimary.withValues(alpha: 0.10)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AuroraSpacing.radiusLg),
            child: InkWell(
              borderRadius: BorderRadius.circular(AuroraSpacing.radiusLg),
              onTap: () => ctrl.setGoal(g),
              child: Container(
                padding: const EdgeInsets.all(AuroraSpacing.lg),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AuroraSpacing.radiusLg),
                  border: Border.all(
                    color: selected
                        ? AuroraColors.coralPrimary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(g.label,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    if (selected)
                      const Icon(Icons.check_circle_rounded,
                          color: AuroraColors.coralPrimary),
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
