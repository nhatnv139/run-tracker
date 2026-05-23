import 'package:flutter/material.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/data/models/heatmap_data.dart';

/// GitHub-style 53×7 calendar heatmap. Each cell is `cellSize` square.
class HeatmapGrid extends StatelessWidget {
  const HeatmapGrid({
    required this.data,
    this.endDate,
    this.cellSize = 12,
    this.cellGap = 3,
    this.onCellTap,
    super.key,
  });

  /// Pre-grouped buckets keyed by local-midnight date.
  final Map<DateTime, HeatmapBucket> data;
  final DateTime? endDate;
  final double cellSize;
  final double cellGap;
  final void Function(DateTime date, HeatmapBucket? bucket)? onCellTap;

  Color _cellColor(BuildContext context, int intensity) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    switch (intensity) {
      case 1:
        return AuroraColors.mintSecondary.withValues(alpha: 0.30);
      case 2:
        return AuroraColors.mintSecondary.withValues(alpha: 0.55);
      case 3:
        return AuroraColors.coralPrimary.withValues(alpha: 0.70);
      case 4:
        return AuroraColors.coralPrimary;
      case 0:
      default:
        return isDark
            ? AuroraColors.surfaceDarkAlt
            : AuroraColors.surfaceLightAlt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime anchor = endDate ?? DateTime.now();
    final DateTime endDay = DateTime(anchor.year, anchor.month, anchor.day);
    final int daysFromMonday = endDay.weekday - DateTime.monday;
    final DateTime weekEnd = endDay.add(Duration(days: 7 - daysFromMonday));
    final DateTime gridStart = weekEnd.subtract(const Duration(days: 53 * 7));

    return SizedBox(
      height: 7 * (cellSize + cellGap) + 20,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: AuroraSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _MonthLabels(
              start: gridStart,
              cellSize: cellSize,
              cellGap: cellGap,
              textColor: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (int week = 0; week < 53; week++)
                  Padding(
                    padding: EdgeInsets.only(right: cellGap),
                    child: Column(
                      children: <Widget>[
                        for (int day = 0; day < 7; day++)
                          _Cell(
                            date: gridStart
                                .add(Duration(days: week * 7 + day)),
                            cellSize: cellSize,
                            cellGap: cellGap,
                            buckets: data,
                            today: endDay,
                            colorFor: (int intensity) =>
                                _cellColor(context, intensity),
                            onTap: onCellTap,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.date,
    required this.cellSize,
    required this.cellGap,
    required this.buckets,
    required this.today,
    required this.colorFor,
    this.onTap,
  });

  final DateTime date;
  final double cellSize;
  final double cellGap;
  final Map<DateTime, HeatmapBucket> buckets;
  final DateTime today;
  final Color Function(int intensity) colorFor;
  final void Function(DateTime, HeatmapBucket?)? onTap;

  @override
  Widget build(BuildContext context) {
    final bool inFuture = date.isAfter(today);
    final HeatmapBucket? bucket = buckets[date];
    final int intensity = bucket?.intensity ?? 0;
    return Padding(
      padding: EdgeInsets.only(bottom: cellGap),
      child: GestureDetector(
        onTap: onTap == null || inFuture ? null : () => onTap!(date, bucket),
        child: Container(
          width: cellSize,
          height: cellSize,
          decoration: BoxDecoration(
            color: inFuture
                ? Colors.transparent
                : colorFor(intensity).withValues(alpha: inFuture ? 0 : 1),
            borderRadius: BorderRadius.circular(3),
            border: date == today
                ? Border.all(color: AuroraColors.coralPrimary, width: 1.4)
                : null,
          ),
        ),
      ),
    );
  }
}

class _MonthLabels extends StatelessWidget {
  const _MonthLabels({
    required this.start,
    required this.cellSize,
    required this.cellGap,
    required this.textColor,
  });

  final DateTime start;
  final double cellSize;
  final double cellGap;
  final Color textColor;

  static const List<String> _monthShort = <String>[
    '', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'T10', 'T11', 'T12',
  ];

  @override
  Widget build(BuildContext context) {
    int? lastMonth;
    final List<Widget> children = <Widget>[];
    for (int week = 0; week < 53; week++) {
      final DateTime weekStart = start.add(Duration(days: week * 7));
      final bool firstFullWeekOfMonth = weekStart.day <= 7;
      final String? label = firstFullWeekOfMonth && weekStart.month != lastMonth
          ? _monthShort[weekStart.month]
          : null;
      lastMonth = weekStart.month;
      children.add(SizedBox(
        width: cellSize + cellGap,
        child: Text(
          label ?? '',
          style: TextStyle(fontSize: 9, color: textColor),
        ),
      ));
    }
    return Row(children: children);
  }
}
