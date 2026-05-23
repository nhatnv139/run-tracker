import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/data/models/activity.dart';
import 'package:runvie/features/activity/presentation/widgets/route_thumbnail.dart';
import 'package:runvie/shared/extensions/duration_extensions.dart';
import 'package:runvie/shared/utils/distance_utils.dart';
import 'package:runvie/shared/widgets/aurora_card.dart';

class ActivityListTile extends StatelessWidget {
  const ActivityListTile({
    required this.activity,
    required this.onTap,
    super.key,
  });

  final Activity activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final DateFormat fmt = DateFormat("d 'thg' M • HH:mm", 'vi_VN');
    final Color subdued = Theme.of(context).colorScheme.outline;
    final Duration paceDur = Duration(seconds: activity.avgPaceSecPerKm.round());

    return AuroraCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AuroraSpacing.md),
      child: Row(
        children: <Widget>[
          RouteThumbnail(encoded: activity.encodedPolyline),
          const SizedBox(width: AuroraSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(_iconFor(activity.type),
                        size: 14, color: AuroraColors.coralPrimary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        fmt.format(activity.startedAt),
                        style: text.labelMedium?.copyWith(color: subdued),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${DistanceUtils.formatKm(activity.distanceMeters)} km',
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Wrap(
                  spacing: AuroraSpacing.sm,
                  children: <Widget>[
                    _Stat(
                        label: activity.duration.clockFormat,
                        icon: Icons.timer_outlined),
                    _Stat(
                        label: '${paceDur.paceFormat}/km',
                        icon: Icons.speed_rounded),
                    _Stat(
                        label: '${activity.calories.round()} kcal',
                        icon: Icons.local_fire_department_rounded),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }

  IconData _iconFor(ActivityType type) {
    switch (type) {
      case ActivityType.run:
        return Icons.directions_run_rounded;
      case ActivityType.walk:
        return Icons.directions_walk_rounded;
      case ActivityType.treadmill:
        return Icons.fitness_center_rounded;
      case ActivityType.trail:
        return Icons.terrain_rounded;
    }
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.icon});
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final Color subdued = Theme.of(context).colorScheme.outline;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 13, color: subdued),
        const SizedBox(width: 2),
        Text(label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: subdued)),
      ],
    );
  }
}
