import 'package:flutter/material.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/data/models/activity.dart';
import 'package:runvie/shared/extensions/duration_extensions.dart';

class SplitsTable extends StatelessWidget {
  const SplitsTable({required this.splits, super.key});
  final List<ActivitySplit> splits;

  @override
  Widget build(BuildContext context) {
    if (splits.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AuroraSpacing.md),
        child: Text('Chưa có split nào',
            style: Theme.of(context).textTheme.bodyMedium),
      );
    }
    final int fastestSec = splits
        .map((ActivitySplit s) => s.duration.inSeconds)
        .reduce((int a, int b) => a < b ? a : b);
    return Column(
      children: <Widget>[
        const _HeaderRow(),
        const Divider(height: 1),
        for (final ActivitySplit s in splits)
          _SplitRow(split: s, isFastest: s.duration.inSeconds == fastestSec),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();
  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.outline,
          fontWeight: FontWeight.w600,
        );
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AuroraSpacing.sm, vertical: AuroraSpacing.xs),
      child: Row(
        children: <Widget>[
          SizedBox(width: 32, child: Text('Km', style: style)),
          Expanded(child: Text('Pace', style: style)),
          Text('Cao độ', style: style),
        ],
      ),
    );
  }
}

class _SplitRow extends StatelessWidget {
  const _SplitRow({required this.split, required this.isFastest});
  final ActivitySplit split;
  final bool isFastest;

  @override
  Widget build(BuildContext context) {
    final Color subdued = Theme.of(context).colorScheme.outline;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AuroraSpacing.sm, vertical: AuroraSpacing.xs),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 32,
            child: Text('${split.km}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Text(split.duration.paceFormat,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isFastest ? AuroraColors.coralPrimary : null,
                    )),
                if (isFastest) ...<Widget>[
                  const SizedBox(width: 4),
                  const Icon(Icons.bolt_rounded,
                      size: 14, color: AuroraColors.coralPrimary),
                ],
              ],
            ),
          ),
          Text('+${split.elevationGain.round()} m',
              style: TextStyle(color: subdued)),
        ],
      ),
    );
  }
}
