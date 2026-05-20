import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runvie/core/router/routes.dart';
import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/features/onboarding/presentation/_onboarding_layout.dart';
import 'package:runvie/features/onboarding/providers/onboarding_provider.dart';
import 'package:runvie/shared/widgets/aurora_button.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OnboardingLayout(
      step: 5,
      title: 'Nhắc bạn chạy nhé?',
      subtitle:
          'RunVie gửi 1-2 thông báo mỗi tuần để giữ thói quen — không spam.',
      primary: AuroraButton(
        label: 'Cho phép',
        variant: AuroraButtonVariant.gradient,
        onPressed: () {
          ref
              .read(onboardingControllerProvider.notifier)
              .setNotificationsOptIn(true);
          context.push(AppRoutes.onboardingPermission);
        },
      ),
      secondary: AuroraButton(
        label: 'Để sau',
        variant: AuroraButtonVariant.ghost,
        onPressed: () => context.push(AppRoutes.onboardingPermission),
      ),
      child: Center(
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AuroraColors.lavenderTertiary.withValues(alpha: 0.10),
          ),
          child: const Icon(
            Icons.notifications_active_rounded,
            size: 80,
            color: AuroraColors.lavenderTertiary,
          ),
        ),
      ),
    );
  }
}
