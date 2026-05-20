import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runvie/core/router/routes.dart';
import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/shared/widgets/aurora_button.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AuroraSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => context.go(AppRoutes.home),
                ),
              ),
              const SizedBox(height: AuroraSpacing.md),
              ShaderMask(
                shaderCallback: (Rect r) =>
                    AuroraColors.auroraLinear.createShader(r),
                child: Text(
                  'RunVie Pro',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const SizedBox(height: AuroraSpacing.sm),
              Text(
                'Mở khóa HLV AI tiếng Việt, kế hoạch cá nhân hóa và phân tích nâng cao.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AuroraSpacing.xl),
              const _Bullet('HLV AI hướng dẫn theo thời gian thực'),
              const _Bullet('Kế hoạch luyện 5K / 10K / Half'),
              const _Bullet('Đồng bộ Apple Health / Google Fit'),
              const _Bullet('Phân tích kỹ thuật chạy chuyên sâu'),
              const _Bullet('Không quảng cáo, không giới hạn'),
              const Spacer(),
              const _PricePill(
                price: '99.000 đ',
                period: '/ tháng',
                savings: 'Tiết kiệm 40% với gói năm',
              ),
              const SizedBox(height: AuroraSpacing.lg),
              AuroraButton(
                label: 'Bắt đầu dùng thử 7 ngày miễn phí',
                variant: AuroraButtonVariant.gradient,
                onPressed: () => context.go(AppRoutes.home),
              ),
              const SizedBox(height: AuroraSpacing.sm),
              AuroraButton(
                label: 'Để sau',
                variant: AuroraButtonVariant.ghost,
                onPressed: () => context.go(AppRoutes.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AuroraSpacing.xs),
      child: Row(
        children: <Widget>[
          const Icon(Icons.check_circle_rounded,
              color: AuroraColors.mintSecondary, size: 22),
          const SizedBox(width: AuroraSpacing.sm),
          Expanded(
            child:
                Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _PricePill extends StatelessWidget {
  const _PricePill({
    required this.price,
    required this.period,
    required this.savings,
  });

  final String price;
  final String period;
  final String savings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AuroraSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AuroraSpacing.radiusLg),
        border: Border.all(
          color: AuroraColors.coralPrimary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(price,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              Text(period, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 4),
          Text(savings,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AuroraColors.coralPrimary,
                    fontWeight: FontWeight.w600,
                  )),
        ],
      ),
    );
  }
}
