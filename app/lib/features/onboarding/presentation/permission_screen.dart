import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runvie/core/router/routes.dart';
import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/features/onboarding/presentation/_onboarding_layout.dart';
import 'package:runvie/features/onboarding/providers/onboarding_provider.dart';
import 'package:runvie/shared/widgets/aurora_button.dart';

class PermissionScreen extends ConsumerWidget {
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OnboardingLayout(
      step: 6,
      title: 'Cấp quyền vị trí',
      subtitle:
          'RunVie cần truy cập GPS và cảm biến chuyển động để ghi lại buổi chạy chính xác.',
      primary: AuroraButton(
        label: 'Cấp quyền',
        variant: AuroraButtonVariant.gradient,
        onPressed: () {
          ref
              .read(onboardingControllerProvider.notifier)
              .setPermissionGranted(true);
          context.push(AppRoutes.onboardingPaywall);
        },
      ),
      secondary: AuroraButton(
        label: 'Bỏ qua',
        variant: AuroraButtonVariant.ghost,
        onPressed: () => context.push(AppRoutes.onboardingPaywall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const <Widget>[
          _PermItem(
            icon: Icons.location_on_rounded,
            color: AuroraColors.coralPrimary,
            title: 'Vị trí GPS',
            body: 'Đo quãng đường và vẽ bản đồ. Hoạt động cả khi tắt màn hình.',
          ),
          SizedBox(height: AuroraSpacing.lg),
          _PermItem(
            icon: Icons.directions_walk_rounded,
            color: AuroraColors.mintSecondary,
            title: 'Cảm biến chuyển động',
            body: 'Đếm bước, phát hiện chạy/đi để tính calo chính xác.',
          ),
          SizedBox(height: AuroraSpacing.lg),
          _PermItem(
            icon: Icons.favorite_rounded,
            color: AuroraColors.lavenderTertiary,
            title: 'Sức khỏe (tùy chọn)',
            body: 'Đồng bộ nhịp tim từ đồng hồ thông minh nếu có.',
          ),
        ],
      ),
    );
  }
}

class _PermItem extends StatelessWidget {
  const _PermItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AuroraSpacing.radiusMd),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: AuroraSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(body, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
