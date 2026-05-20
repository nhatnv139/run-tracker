import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/shared/widgets/aurora_card.dart';
import 'package:runvie/shared/widgets/ring_progress.dart';
import 'package:runvie/shared/widgets/streak_chip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: pull from real providers
    const double weeklyProgress = 0.42;
    const double weeklyTargetKm = 20;
    const double weeklyDoneKm = 8.4;
    const int streakDays = 5;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AuroraSpacing.xl,
            AuroraSpacing.lg,
            AuroraSpacing.xl,
            AuroraSpacing.huge,
          ),
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Xin chào,',
                          style: Theme.of(context).textTheme.bodyMedium),
                      Text('Sẵn sàng chạy chưa?',
                          style:
                              Theme.of(context).textTheme.headlineSmall),
                    ],
                  ),
                ),
                const StreakChip(days: streakDays),
              ],
            ),
            const SizedBox(height: AuroraSpacing.xl),
            AuroraCard(
              padding: const EdgeInsets.all(AuroraSpacing.xl),
              child: Column(
                children: <Widget>[
                  Text('Mục tiêu tuần này',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AuroraSpacing.lg),
                  RingProgress(
                    progress: weeklyProgress,
                    size: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          weeklyDoneKm.toStringAsFixed(1),
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '/ ${weeklyTargetKm.toStringAsFixed(0)} km',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AuroraSpacing.md),
                  Text(
                    'Còn ${(weeklyTargetKm - weeklyDoneKm).toStringAsFixed(1)} km nữa thôi!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AuroraColors.coralPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AuroraSpacing.lg),
            Text('Gợi ý hôm nay',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AuroraSpacing.sm),
            AuroraCard(
              child: Row(
                children: <Widget>[
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: AuroraColors.auroraLinear,
                      borderRadius:
                          BorderRadius.circular(AuroraSpacing.radiusMd),
                    ),
                    child: const Icon(
                      Icons.directions_run_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AuroraSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Chạy nhẹ 3 km',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(
                          'Tốc độ thoải mái, 20-25 phút',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
