import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runvie/core/router/routes.dart';
import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/shared/widgets/aurora_button.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AuroraSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Spacer(),
              Container(
                width: 140,
                height: 140,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AuroraColors.auroraLinear,
                ),
                child: const Icon(
                  Icons.directions_run_rounded,
                  size: 72,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AuroraSpacing.xxl),
              Text(
                'Chạy bộ vui hơn\ncùng RunVie',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AuroraSpacing.md),
              Text(
                'Theo dõi quãng đường, được HLV AI hướng dẫn bằng tiếng Việt, và giữ thói quen mỗi ngày.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
              ),
              const Spacer(),
              AuroraButton(
                label: 'Bắt đầu',
                variant: AuroraButtonVariant.gradient,
                onPressed: () => context.push(AppRoutes.onboardingGoal),
              ),
              const SizedBox(height: AuroraSpacing.sm),
              AuroraButton(
                label: 'Đã có tài khoản? Đăng nhập',
                variant: AuroraButtonVariant.ghost,
                onPressed: () => context.push(AppRoutes.signIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
