import 'package:flutter/material.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';

/// Inline card rendered inside the coach bubble when the SSE stream
/// returns a `plan` event. Accepts a raw map shaped roughly like:
/// ```json
/// {
///   "title": "Sub-50 10K - 12 tuần",
///   "weeks": 12,
///   "weekly_volume_km": 35,
///   "key_workouts": ["Tempo 5K @ Z3", "Long run 14 km", "Intervals 6x800m"]
/// }
/// ```
class TrainingPlanCard extends StatelessWidget {
  const TrainingPlanCard({
    required this.planJson,
    required this.onApply,
    super.key,
  });

  final Map<String, dynamic> planJson;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String title = (planJson['title'] as String?) ?? 'Giáo án đề xuất';
    final int? weeks = (planJson['weeks'] as num?)?.toInt();
    final num? volume = planJson['weekly_volume_km'] as num?;
    final List<dynamic> keyWorkouts =
        (planJson['key_workouts'] as List<dynamic>?) ?? const <dynamic>[];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            AuroraColors.lavenderTertiary.withOpacity(0.18),
            AuroraColors.mintSecondary.withOpacity(0.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AuroraSpacing.radiusLg),
        border: Border.all(
          color: AuroraColors.lavenderTertiary.withOpacity(0.4),
        ),
      ),
      padding: const EdgeInsets.all(AuroraSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.calendar_month,
                color: AuroraColors.lavenderTertiary,
              ),
              const SizedBox(width: AuroraSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (weeks != null || volume != null) ...<Widget>[
            const SizedBox(height: AuroraSpacing.sm),
            Wrap(
              spacing: AuroraSpacing.sm,
              runSpacing: AuroraSpacing.xs,
              children: <Widget>[
                if (weeks != null)
                  _PlanChip(label: '$weeks tuần', icon: Icons.event),
                if (volume != null)
                  _PlanChip(
                    label: '${volume.toStringAsFixed(0)} km/tuần',
                    icon: Icons.directions_run,
                  ),
              ],
            ),
          ],
          if (keyWorkouts.isNotEmpty) ...<Widget>[
            const SizedBox(height: AuroraSpacing.sm),
            ...keyWorkouts.take(4).map((dynamic w) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(top: 6, right: 6),
                      child: Icon(
                        Icons.fiber_manual_record,
                        size: 6,
                        color: AuroraColors.mintSecondary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        w.toString(),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: AuroraSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onApply,
              style: FilledButton.styleFrom(
                backgroundColor: AuroraColors.lavenderTertiary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AuroraSpacing.radiusMd),
                ),
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Áp dụng vào lịch của tôi'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanChip extends StatelessWidget {
  const _PlanChip({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AuroraSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(AuroraSpacing.radiusPill),
        border: Border.all(
          color: AuroraColors.lavenderTertiary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: AuroraColors.lavenderTertiary),
          const SizedBox(width: 4),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
