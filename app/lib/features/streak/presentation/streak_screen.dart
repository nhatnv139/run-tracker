import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/data/repositories/coin_repository.dart';
import 'package:runvie/features/streak/streak_calc.dart';
import 'package:runvie/features/streak/streak_providers.dart';
import 'package:runvie/features/streak/streak_state.dart';
import 'package:runvie/services/supabase_service.dart';
import 'package:runvie/shared/widgets/aurora_button.dart';
import 'package:runvie/shared/widgets/aurora_card.dart';

class StreakScreen extends ConsumerWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StreakState s = ref.watch(streakControllerProvider);
    final StreakCalculator calc = ref.watch(streakCalculatorProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Chuoi ngay chay')),
      body: ListView(
        padding: const EdgeInsets.all(AuroraSpacing.lg),
        children: <Widget>[
          _StreakHeader(state: s),
          const SizedBox(height: AuroraSpacing.lg),
          AuroraCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _StatRow(
                  label: 'Hien tai',
                  value: '${s.currentDays} ngay',
                ),
                const Divider(height: AuroraSpacing.lg),
                _StatRow(
                  label: 'Ky luc',
                  value: '${s.longestDays} ngay',
                ),
                const Divider(height: AuroraSpacing.lg),
                _StatRow(
                  label: 'Freeze con',
                  value: '${s.freezesRemaining}',
                ),
              ],
            ),
          ),
          const SizedBox(height: AuroraSpacing.lg),
          AuroraCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Mua them Freeze',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AuroraSpacing.xs),
                Text(
                  'Gia ${calc.freezeBuyCost} RunCoin. Toi da ${calc.monthlyBuyCap} freeze/thang. Da mua ${s.monthlyFreezesBought}.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AuroraSpacing.md),
                AuroraButton(
                  label: 'Mua 1 Freeze',
                  variant: AuroraButtonVariant.gradient,
                  onPressed: calc.canBuyFreeze(s)
                      ? () => _buyFreeze(context, ref)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _buyFreeze(BuildContext context, WidgetRef ref) async {
    final String? uid = SupabaseService.instance.currentUser?.id;
    if (uid == null) return;
    final bool ok = await ref.read(streakControllerProvider.notifier).buyFreeze(
          userId: uid,
          coinRepo: ref.read(coinRepositoryProvider),
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Da them 1 Freeze!'
            : 'Khong du RunCoin hoac da het luot mua thang nay'),
      ),
    );
  }
}

class _StreakHeader extends StatelessWidget {
  const _StreakHeader({required this.state});
  final StreakState state;

  @override
  Widget build(BuildContext context) {
    final bool active = state.isActive;
    final Color iconColor =
        active ? AuroraColors.coralPrimary : AuroraColors.textTertiaryLight;
    return Column(
      children: <Widget>[
        Icon(
          Icons.local_fire_department_rounded,
          size: 96,
          color: iconColor,
        ),
        const SizedBox(height: AuroraSpacing.sm),
        Text(
          '${state.currentDays}',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: iconColor,
              ),
        ),
        Text(
          active ? 'NGAY LIEN TIEP' : 'CHUOI DA GAY',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        if (state.frozenToday) ...<Widget>[
          const SizedBox(height: AuroraSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AuroraSpacing.md,
              vertical: AuroraSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AuroraColors.info.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AuroraSpacing.radiusPill),
            ),
            child: const Text(
              'Da dung Freeze hom nay',
              style: TextStyle(color: AuroraColors.info),
            ),
          ),
        ],
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}
