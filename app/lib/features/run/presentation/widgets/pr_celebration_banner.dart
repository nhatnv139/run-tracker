import 'package:flutter/material.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/data/models/personal_record.dart';
import 'package:runvie/shared/extensions/duration_extensions.dart';

class PrCelebrationBanner extends StatelessWidget {
  const PrCelebrationBanner({required this.achievements, super.key});

  final List<PrAchievement> achievements;

  String _format(PrAchievement a) {
    switch (a.kind) {
      case PrKind.fastest1k:
      case PrKind.fastest5k:
      case PrKind.fastest10k:
      case PrKind.fastestHalfMarathon:
      case PrKind.fastestMarathon:
        return Duration(seconds: a.newValue.round()).clockFormat;
      case PrKind.longestRun:
        return '${(a.newValue / 1000).toStringAsFixed(2)} km';
      case PrKind.biggestElevation:
        return '${a.newValue.round()} m';
      case PrKind.longestStreak:
        return '${a.newValue.round()} ngày';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(AuroraSpacing.lg),
      decoration: BoxDecoration(
        gradient: AuroraColors.auroraLinear,
        borderRadius: BorderRadius.circular(AuroraSpacing.radiusXl),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AuroraColors.coralPrimary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: const <Widget>[
              Icon(Icons.emoji_events_rounded, color: Colors.white, size: 28),
              SizedBox(width: AuroraSpacing.sm),
              Text('Kỷ lục mới!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  )),
            ],
          ),
          const SizedBox(height: AuroraSpacing.sm),
          for (final PrAchievement a in achievements)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: <Widget>[
                  const Text('• ',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  Text(a.kind.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      )),
                  const Spacer(),
                  Text(_format(a),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
