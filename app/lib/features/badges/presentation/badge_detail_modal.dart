import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/data/models/badge.dart';
import 'package:runvie/shared/widgets/aurora_button.dart';

Future<void> showBadgeDetailModal({
  required BuildContext context,
  required BadgeModel badge,
  required bool earned,
  DateTime? earnedAt,
  double progress = 0,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (BuildContext ctx) => _BadgeDetailSheet(
      badge: badge,
      earned: earned,
      earnedAt: earnedAt,
      progress: progress,
    ),
  );
}

class _BadgeDetailSheet extends StatefulWidget {
  const _BadgeDetailSheet({
    required this.badge,
    required this.earned,
    this.earnedAt,
    this.progress = 0,
  });

  final BadgeModel badge;
  final bool earned;
  final DateTime? earnedAt;
  final double progress;

  @override
  State<_BadgeDetailSheet> createState() => _BadgeDetailSheetState();
}

class _BadgeDetailSheetState extends State<_BadgeDetailSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (widget.earned) {
      _glow.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BadgeModel b = widget.badge;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AuroraSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedBuilder(
              animation: _glow,
              builder: (BuildContext context, Widget? child) {
                final double t = _glow.value;
                return Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.earned
                        ? AuroraColors.auroraLinear
                        : LinearGradient(
                            colors: <Color>[
                              AuroraColors.textTertiaryLight,
                              AuroraColors.textTertiaryLight
                                  .withValues(alpha: 0.4),
                            ],
                          ),
                    boxShadow: <BoxShadow>[
                      if (widget.earned)
                        BoxShadow(
                          color: AuroraColors.coralPrimary
                              .withValues(alpha: 0.25 + 0.45 * t),
                          blurRadius: 24 + 12 * t,
                          spreadRadius: 2 + 4 * t,
                        ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.emoji_events_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AuroraSpacing.lg),
            Text(
              widget.earned || !b.isHidden ? b.nameVi : '???',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text(
              widget.earned || !b.isHidden ? b.nameEn : 'Hidden',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AuroraSpacing.md),
            Text(
              widget.earned || !b.isHidden
                  ? b.descriptionVi
                  : 'Huy hieu bi an — chay tiep de kham pha!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AuroraSpacing.sm),
            Text(
              b.descriptionEn,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AuroraColors.textTertiaryLight,
                  ),
            ),
            const SizedBox(height: AuroraSpacing.lg),
            if (widget.earned) ...<Widget>[
              if (widget.earnedAt != null)
                Text(
                  'Mo khoa ngay ${_fmt(widget.earnedAt!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: AuroraSpacing.md),
              AuroraButton(
                label: 'Chia se',
                icon: Icons.share_rounded,
                variant: AuroraButtonVariant.gradient,
                onPressed: () {
                  Share.share(
                    'Vua nhan huy hieu "${b.nameVi}" tren RunVie!',
                  );
                },
              ),
            ] else ...<Widget>[
              _CriteriaInfo(badge: b),
              const SizedBox(height: AuroraSpacing.md),
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(AuroraSpacing.radiusPill),
                child: LinearProgressIndicator(
                  value: widget.progress.clamp(0, 1),
                  minHeight: 8,
                  color: AuroraColors.coralPrimary,
                  backgroundColor: AuroraColors.surfaceLightAlt,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _CriteriaInfo extends StatelessWidget {
  const _CriteriaInfo({required this.badge});
  final BadgeModel badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AuroraSpacing.md),
      decoration: BoxDecoration(
        color: AuroraColors.surfaceLightAlt,
        borderRadius: BorderRadius.circular(AuroraSpacing.radiusMd),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.flag_rounded,
              size: 20, color: AuroraColors.coralPrimary),
          const SizedBox(width: AuroraSpacing.sm),
          Expanded(
            child: Text(
              _criteriaLabel(badge),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _criteriaLabel(BadgeModel b) {
    switch (b.criteriaType) {
      case BadgeCriteriaType.distanceSingleKm:
        return 'Chay ${b.criteriaValue.toStringAsFixed(b.criteriaValue % 1 == 0 ? 0 : 1)}km trong 1 buoi';
      case BadgeCriteriaType.distanceTotalKm:
        return 'Tich luy ${b.criteriaValue.toStringAsFixed(0)}km';
      case BadgeCriteriaType.streakDays:
        return 'Duy tri ${b.criteriaValue.toStringAsFixed(0)} ngay lien tiep';
      case BadgeCriteriaType.timeOfDay:
        return 'Chay trong khung ${b.criteriaHourStart}h - ${b.criteriaHourEnd}h, ${b.criteriaValue.toStringAsFixed(0)} buoi';
      case BadgeCriteriaType.paceSub5K:
        return 'Pace duoi ${(b.criteriaValue / 60).toStringAsFixed(0)}p/km tren 5K';
      case BadgeCriteriaType.negativeSplit:
        return 'Negative split (nua sau nhanh hon nua dau)';
      case BadgeCriteriaType.exactDistance:
        return 'Chay chinh xac ${b.criteriaValue}km';
      case BadgeCriteriaType.comebackKing:
        return 'Xay lai chuoi sau khi gay';
      case BadgeCriteriaType.custom:
        return b.descriptionVi;
    }
  }
}
