import 'package:flutter/material.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/data/models/activity.dart';
import 'package:runvie/shared/extensions/duration_extensions.dart';
import 'package:runvie/shared/utils/distance_utils.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({required this.activity, super.key});
  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final Duration pace = Duration(seconds: activity.avgPaceSecPerKm.round());
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            _Cell(
              icon: Icons.straighten_rounded,
              color: AuroraColors.coralPrimary,
              label: 'Cự ly',
              value: '${DistanceUtils.formatKm(activity.distanceMeters)} km',
            ),
            _Cell(
              icon: Icons.timer_outlined,
              color: AuroraColors.mintSecondary,
              label: 'Thời gian',
              value: activity.duration.clockFormat,
            ),
          ],
        ),
        const SizedBox(height: AuroraSpacing.sm),
        Row(
          children: <Widget>[
            _Cell(
              icon: Icons.speed_rounded,
              color: AuroraColors.lavenderTertiary,
              label: 'Pace TB',
              value: '${pace.paceFormat}/km',
            ),
            _Cell(
              icon: Icons.local_fire_department_rounded,
              color: AuroraColors.warning,
              label: 'Năng lượng',
              value: '${activity.calories.round()} kcal',
            ),
          ],
        ),
        const SizedBox(height: AuroraSpacing.sm),
        Row(
          children: <Widget>[
            _Cell(
              icon: Icons.terrain_rounded,
              color: AuroraColors.success,
              label: 'Leo dốc',
              value: '+${activity.elevationGainM.round()} m',
            ),
            _Cell(
              icon: Icons.favorite_rounded,
              color: AuroraColors.error,
              label: 'Nhịp tim TB',
              value: activity.avgHr != null ? '${activity.avgHr} bpm' : '—',
            ),
          ],
        ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(AuroraSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AuroraSpacing.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, size: 18, color: color),
            const SizedBox(height: AuroraSpacing.xs),
            Text(label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    )),
            const SizedBox(height: 2),
            Text(value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
          ],
        ),
      ),
    );
  }
}
