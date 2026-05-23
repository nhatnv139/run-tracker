import 'package:flutter/material.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/data/models/period_stats.dart';
import 'package:runvie/shared/extensions/duration_extensions.dart';
import 'package:runvie/shared/utils/distance_utils.dart';
import 'package:runvie/shared/widgets/aurora_card.dart';

class PeriodSummaryCard extends StatelessWidget {
  const PeriodSummaryCard({required this.stats, super.key});

  final PeriodStats stats;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Color subdued = Theme.of(context).colorScheme.outline;
    return AuroraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(stats.period.label,
              style: text.titleMedium?.copyWith(
                color: AuroraColors.coralPrimary,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: AuroraSpacing.md),
          Row(
            children: <Widget>[
              _Tile(
                label: 'Quãng đường',
                value: '${DistanceUtils.formatKm(stats.totalMeters)} km',
                subdued: subdued,
              ),
              _Tile(
                label: 'Thời gian',
                value: stats.totalDuration.clockFormat,
                subdued: subdued,
              ),
            ],
          ),
          const SizedBox(height: AuroraSpacing.md),
          Row(
            children: <Widget>[
              _Tile(
                label: 'Buổi chạy',
                value: stats.totalRuns.toString(),
                subdued: subdued,
              ),
              _Tile(
                label: 'Năng lượng',
                value: '${stats.totalCalories.round()} kcal',
                subdued: subdued,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.label,
    required this.value,
    required this.subdued,
  });

  final String label;
  final String value;
  final Color subdued;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: subdued),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
