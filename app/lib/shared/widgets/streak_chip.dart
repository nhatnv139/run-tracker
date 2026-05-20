import 'package:flutter/material.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';

class StreakChip extends StatelessWidget {
  const StreakChip({required this.days, super.key});
  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AuroraSpacing.md,
        vertical: AuroraSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: AuroraColors.auroraLinear,
        borderRadius: BorderRadius.circular(AuroraSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.local_fire_department_rounded,
              color: Colors.white, size: 16),
          const SizedBox(width: AuroraSpacing.xs),
          Text(
            '$days ngày',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
