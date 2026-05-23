import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:runvie/core/router/routes.dart';
import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/data/models/activity.dart';
import 'package:runvie/data/models/personal_record.dart';
import 'package:runvie/data/models/pr_detector.dart';
import 'package:runvie/features/activity/presentation/widgets/route_thumbnail.dart';
import 'package:runvie/features/activity/presentation/widgets/splits_table.dart';
import 'package:runvie/features/activity/presentation/widgets/stats_grid.dart';
import 'package:runvie/features/activity/providers/activity_providers.dart';
import 'package:runvie/features/run/presentation/widgets/pr_celebration_banner.dart';
import 'package:runvie/features/run/presentation/widgets/rpe_picker.dart';
import 'package:runvie/features/run/presentation/widgets/share_action.dart';
import 'package:runvie/features/run/presentation/widgets/share_card_9_16.dart';
import 'package:runvie/services/analytics_events.dart';
import 'package:runvie/services/analytics_service.dart';
import 'package:runvie/shared/utils/distance_utils.dart';
import 'package:runvie/shared/utils/gpx_exporter.dart';
import 'package:runvie/shared/widgets/aurora_button.dart';
import 'package:runvie/shared/widgets/aurora_card.dart';

class PostRunScreen extends ConsumerStatefulWidget {
  const PostRunScreen({required this.activityId, super.key});
  final int activityId;

  @override
  ConsumerState<PostRunScreen> createState() => _PostRunScreenState();
}

class _PostRunScreenState extends ConsumerState<PostRunScreen> {
  final GlobalKey _shareKey = GlobalKey();
  int? _rpe;
  List<PrAchievement> _achievements = const <PrAchievement>[];
  bool _achievementsResolved = false;

  Future<void> _resolveAchievements(Activity newActivity) async {
    if (_achievementsResolved) return;
    _achievementsResolved = true;
    final List<Activity> history =
        await ref.read(activityRepositoryProvider).getRecent(limit: 500);
    // Existing PRs computed from everything BEFORE this run.
    final List<Activity> prior = history
        .where((Activity a) => a.id != newActivity.id)
        .toList();
    final Map<PrKind, PersonalRecord> existing =
        PrDetector.computeAll(prior);
    final List<PrAchievement> achievements = PrDetector.detect(
      newActivity: newActivity,
      existing: existing,
      historyIncludingNew: history,
    );
    if (mounted) {
      setState(() {
        _achievements = achievements;
      });
    }
  }

  Future<void> _saveRpe(Activity a, int rpe) async {
    setState(() => _rpe = rpe);
    final Activity updated = a.copyWith(rpe: rpe);
    await ref.read(activityRepositoryProvider).save(updated);
    unawaited(ref
        .read(analyticsProvider)
        .track(AnalyticsEvents.rpeRecorded, properties: <String, Object?>{
          'rpe': rpe,
        }));
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Activity?> async$ =
        ref.watch(activityByIdProvider(widget.activityId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: const Text('Hoàn thành'),
      ),
      body: async$.when(
        data: (Activity? a) {
          if (a == null) {
            return const Center(child: Text('Không tìm thấy buổi chạy.'));
          }
          // Side-effect: trigger PR detection once.
          if (!_achievementsResolved) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _resolveAchievements(a);
            });
          }
          return _Body(
            activity: a,
            rpe: _rpe ?? a.rpe,
            onRpe: (int v) => _saveRpe(a, v),
            achievements: _achievements,
            shareKey: _shareKey,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.activity,
    required this.rpe,
    required this.onRpe,
    required this.achievements,
    required this.shareKey,
  });
  final Activity activity;
  final int? rpe;
  final ValueChanged<int> onRpe;
  final List<PrAchievement> achievements;
  final GlobalKey shareKey;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Transform.translate(
          offset: const Offset(-10000, -10000),
          child: RepaintBoundary(
            key: shareKey,
            child: ShareCard916(activity: activity),
          ),
        ),
        ListView(
          padding: const EdgeInsets.all(AuroraSpacing.lg),
          children: <Widget>[
            _Hero(activity: activity),
            const SizedBox(height: AuroraSpacing.md),
            if (achievements.isNotEmpty) ...<Widget>[
              PrCelebrationBanner(achievements: achievements),
              const SizedBox(height: AuroraSpacing.md),
            ],
            AuroraCard(child: RpePicker(value: rpe, onChanged: onRpe)),
            const SizedBox(height: AuroraSpacing.md),
            StatsGrid(activity: activity),
            const SizedBox(height: AuroraSpacing.md),
            if (activity.encodedPolyline != null &&
                activity.encodedPolyline!.isNotEmpty) ...<Widget>[
              AuroraCard(
                padding: const EdgeInsets.all(AuroraSpacing.sm),
                child: RouteThumbnail(
                  encoded: activity.encodedPolyline,
                  size: const Size(double.infinity, 160),
                  stroke: 3,
                ),
              ),
              const SizedBox(height: AuroraSpacing.md),
            ],
            Text('Splits',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AuroraSpacing.sm),
            AuroraCard(
              padding: const EdgeInsets.all(AuroraSpacing.sm),
              child: SplitsTable(splits: activity.splits),
            ),
            const SizedBox(height: AuroraSpacing.xl),
            AuroraButton(
              label: 'Lưu vào nhật ký',
              icon: Icons.check_rounded,
              variant: AuroraButtonVariant.gradient,
              onPressed: () => context.go(AppRoutes.home),
            ),
            const SizedBox(height: AuroraSpacing.sm),
            Row(
              children: <Widget>[
                Expanded(
                  child: AuroraButton(
                    label: 'Chia sẻ',
                    icon: Icons.ios_share_rounded,
                    variant: AuroraButtonVariant.secondary,
                    onPressed: () async {
                      final bool ok = await ShareCardRenderer.shareBoundary(
                          shareKey, activity);
                      if (!context.mounted) return;
                      if (!ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Không chia sẻ được')),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: AuroraSpacing.sm),
                Expanded(
                  child: AuroraButton(
                    label: 'Xuất GPX',
                    icon: Icons.file_download_rounded,
                    variant: AuroraButtonVariant.ghost,
                    onPressed: () async {
                      final String gpx = GpxExporter.build(activity);
                      await Share.share(gpx,
                          subject: 'runvie_${activity.id}.gpx');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AuroraSpacing.xxxl),
          ],
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.activity});
  final Activity activity;
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AuroraSpacing.xl, horizontal: AuroraSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AuroraColors.surfaceBlack : null,
        gradient: isDark ? null : AuroraColors.auroraLinear,
        borderRadius: BorderRadius.circular(AuroraSpacing.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Tuyệt vời!',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              )),
          Text(
            '${DistanceUtils.formatKm(activity.distanceMeters)} km',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 96,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: -2,
            ),
          ),
        ],
      ),
    );
  }
}

