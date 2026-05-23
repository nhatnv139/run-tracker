import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:runvie/core/router/routes.dart';
import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/data/models/activity.dart';
import 'package:runvie/data/models/heatmap_data.dart';
import 'package:runvie/data/models/period_stats.dart';
import 'package:runvie/features/activity/providers/activity_providers.dart';
import 'package:runvie/features/activity/presentation/widgets/activity_list_tile.dart';
import 'package:runvie/features/activity/presentation/widgets/heatmap_grid.dart';
import 'package:runvie/features/activity/presentation/widgets/period_summary_card.dart';
import 'package:runvie/shared/widgets/aurora_button.dart';
import 'package:runvie/shared/widgets/aurora_card.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Activity>> activitiesAsync =
        ref.watch(recentActivitiesProvider);
    final AsyncValue<PeriodStats> statsAsync =
        ref.watch(selectedPeriodStatsProvider);
    final AsyncValue<Map<DateTime, HeatmapBucket>> heatmapAsync =
        ref.watch(heatmapDataProvider);
    final StatsPeriod selected = ref.watch(selectedStatsPeriodProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Hoạt động')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(recentActivitiesProvider);
          ref.invalidate(heatmapDataProvider);
          ref.invalidate(selectedPeriodStatsProvider);
        },
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AuroraSpacing.lg,
                AuroraSpacing.lg,
                AuroraSpacing.lg,
                AuroraSpacing.sm,
              ),
              sliver: SliverToBoxAdapter(
                child: _PeriodSelector(
                  selected: selected,
                  onChanged: (StatsPeriod p) =>
                      ref.read(selectedStatsPeriodProvider.notifier).state = p,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AuroraSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: statsAsync.when(
                  data: (PeriodStats s) => PeriodSummaryCard(stats: s),
                  loading: () => const _StatsSkeleton(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ),
            const SliverToBoxAdapter(
                child: SizedBox(height: AuroraSpacing.md)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AuroraSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: heatmapAsync.when(
                  data: (Map<DateTime, HeatmapBucket> map) => AuroraCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Lịch hoạt động 365 ngày',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: AuroraSpacing.sm),
                        HeatmapGrid(
                          data: map,
                          onCellTap: (DateTime d, HeatmapBucket? b) {
                            final String label = b == null
                                ? 'Không có hoạt động'
                                : '${b.totalKm.toStringAsFixed(2)} km · ${b.activityCount} buổi';
                            final String date =
                                DateFormat('dd/MM/yyyy', 'vi_VN').format(d);
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(SnackBar(
                                content: Text('$date — $label'),
                                duration: const Duration(seconds: 2),
                              ));
                          },
                        ),
                        const SizedBox(height: AuroraSpacing.sm),
                        const _HeatmapLegend(),
                      ],
                    ),
                  ),
                  loading: () => const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ),
            const SliverToBoxAdapter(
                child: SizedBox(height: AuroraSpacing.lg)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AuroraSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: Text('Buổi chạy gần đây',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
            ),
            const SliverToBoxAdapter(
                child: SizedBox(height: AuroraSpacing.sm)),
            activitiesAsync.when(
              data: (List<Activity> list) {
                if (list.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  );
                }
                return SliverList.builder(
                  itemCount: list.length,
                  itemBuilder: (BuildContext context, int i) {
                    final Activity a = list[i];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AuroraSpacing.lg,
                        0,
                        AuroraSpacing.lg,
                        AuroraSpacing.sm,
                      ),
                      child: ActivityListTile(
                        activity: a,
                        onTap: () => context
                            .push(AppRoutes.activityDetailPath(a.id)),
                      ),
                    );
                  },
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: SizedBox(
                  height: 160,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (Object e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AuroraSpacing.lg),
                  child: Text('Không tải được lịch sử: $e'),
                ),
              ),
            ),
            const SliverToBoxAdapter(
                child: SizedBox(height: AuroraSpacing.xxxl)),
          ],
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onChanged});
  final StatsPeriod selected;
  final ValueChanged<StatsPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<StatsPeriod>(
      segments: const <ButtonSegment<StatsPeriod>>[
        ButtonSegment<StatsPeriod>(
            value: StatsPeriod.week, label: Text('Tuần')),
        ButtonSegment<StatsPeriod>(
            value: StatsPeriod.month, label: Text('Tháng')),
        ButtonSegment<StatsPeriod>(
            value: StatsPeriod.year, label: Text('Năm')),
        ButtonSegment<StatsPeriod>(
            value: StatsPeriod.allTime, label: Text('Toàn bộ')),
      ],
      selected: <StatsPeriod>{selected},
      onSelectionChanged: (Set<StatsPeriod> s) => onChanged(s.first),
      showSelectedIcon: false,
    );
  }
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();
  @override
  Widget build(BuildContext context) => const AuroraCard(
        child: SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
      );
}

class _HeatmapLegend extends StatelessWidget {
  const _HeatmapLegend();
  @override
  Widget build(BuildContext context) {
    final Color subdued = Theme.of(context).colorScheme.outline;
    final Color base = Theme.of(context).brightness == Brightness.dark
        ? AuroraColors.surfaceDarkAlt
        : AuroraColors.surfaceLightAlt;
    final List<Color> palette = <Color>[
      base,
      AuroraColors.mintSecondary.withValues(alpha: 0.30),
      AuroraColors.mintSecondary.withValues(alpha: 0.55),
      AuroraColors.coralPrimary.withValues(alpha: 0.70),
      AuroraColors.coralPrimary,
    ];
    return Row(
      children: <Widget>[
        Text('Ít', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: subdued)),
        const SizedBox(width: 4),
        for (final Color c in palette) ...<Widget>[
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
        const SizedBox(width: 4),
        Text('Nhiều', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: subdued)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AuroraSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.directions_run_rounded,
              size: 64, color: AuroraColors.mintSecondary),
          const SizedBox(height: AuroraSpacing.md),
          Text('Chưa có buổi chạy nào',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AuroraSpacing.xs),
          Text(
            'Bắt đầu hành trình đầu tiên — mọi km đều đáng giá.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AuroraSpacing.lg),
          SizedBox(
            width: 200,
            child: AuroraButton(
              label: 'Bắt đầu chạy',
              icon: Icons.play_arrow_rounded,
              variant: AuroraButtonVariant.gradient,
              onPressed: () => context.push(AppRoutes.run),
            ),
          ),
        ],
      ),
    );
  }
}
