import 'package:flutter/material.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/data/models/activity.dart';
import 'package:runvie/features/activity/presentation/widgets/route_thumbnail.dart';
import 'package:runvie/shared/extensions/duration_extensions.dart';
import 'package:runvie/shared/utils/distance_utils.dart';

/// 9:16 share card meant to be wrapped in a RepaintBoundary and rasterized
/// to PNG before sharing via share_plus.
class ShareCard916 extends StatelessWidget {
  const ShareCard916({required this.activity, super.key});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final Duration pace =
        Duration(seconds: activity.avgPaceSecPerKm.round());
    return SizedBox(
      width: 1080,
      height: 1920,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AuroraColors.auroraLinear),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(80, 100, 80, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: const <Widget>[
                  Icon(Icons.directions_run_rounded,
                      color: Colors.white, size: 48),
                  SizedBox(width: 12),
                  Text('RunVie',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      )),
                ],
              ),
              const Spacer(),
              Text(
                '${DistanceUtils.formatKm(activity.distanceMeters)} km',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 220,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: -4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  _Metric(
                      label: 'Thời gian', value: activity.duration.clockFormat),
                  const SizedBox(width: 60),
                  _Metric(label: 'Pace TB', value: '${pace.paceFormat}/km'),
                  const SizedBox(width: 60),
                  _Metric(label: 'kcal', value: activity.calories.round().toString()),
                ],
              ),
              const SizedBox(height: 60),
              if (activity.encodedPolyline != null &&
                  activity.encodedPolyline!.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: RouteThumbnail(
                    encoded: activity.encodedPolyline,
                    size: const Size(920, 360),
                    color: Colors.white,
                    stroke: 6,
                  ),
                ),
              const Spacer(),
              const Text(
                '#RunVie  #ChạyCùngVie',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 30,
            )),
        Text(value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            )),
      ],
    );
  }
}
