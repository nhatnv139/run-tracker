import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/data/models/activity.dart';
import 'package:runvie/features/activity/presentation/widgets/route_thumbnail.dart';
import 'package:runvie/features/activity/presentation/widgets/splits_table.dart';
import 'package:runvie/features/activity/presentation/widgets/stats_grid.dart';
import 'package:runvie/features/activity/providers/activity_providers.dart';
import 'package:runvie/features/run/presentation/widgets/share_action.dart';
import 'package:runvie/features/run/presentation/widgets/share_card_9_16.dart';
import 'package:runvie/shared/utils/gpx_exporter.dart';
import 'package:runvie/shared/widgets/aurora_card.dart';

class ActivityDetailScreen extends ConsumerStatefulWidget {
  const ActivityDetailScreen({required this.activityId, super.key});
  final int activityId;

  @override
  ConsumerState<ActivityDetailScreen> createState() =>
      _ActivityDetailScreenState();
}

class _ActivityDetailScreenState
    extends ConsumerState<ActivityDetailScreen> {
  final GlobalKey _shareKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Activity?> async$ =
        ref.watch(activityByIdProvider(widget.activityId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết buổi chạy'),
        actions: <Widget>[
          async$.maybeWhen(
            data: (Activity? a) => a == null
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () => _confirmDelete(context, ref, a),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: async$.when(
        data: (Activity? a) {
          if (a == null) {
            return const Center(child: Text('Không tìm thấy buổi chạy.'));
          }
          return _DetailBody(activity: a, shareKey: _shareKey);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Activity a) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext c) => AlertDialog(
        title: const Text('Xóa buổi chạy?'),
        content: const Text('Hành động này không thể hoàn tác.'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AuroraColors.error),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(activityRepositoryProvider).delete(a.id);
      if (!context.mounted) return;
      context.pop();
    }
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.activity, required this.shareKey});
  final Activity activity;
  final GlobalKey shareKey;

  @override
  Widget build(BuildContext context) {
    final DateFormat fmt = DateFormat("EEEE, d 'thg' M y · HH:mm", 'vi_VN');
    return Stack(
      children: <Widget>[
        // Off-screen render target for share card.
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
            Text(activity.type.label,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: AuroraColors.coralPrimary)),
            Text(fmt.format(activity.startedAt),
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AuroraSpacing.md),
            if (activity.encodedPolyline != null &&
                activity.encodedPolyline!.isNotEmpty)
              AuroraCard(
                padding: const EdgeInsets.all(AuroraSpacing.sm),
                child: RouteThumbnail(
                  encoded: activity.encodedPolyline,
                  size: const Size(double.infinity, 180),
                  stroke: 3.5,
                ),
              ),
            const SizedBox(height: AuroraSpacing.md),
            Text('Tổng quan',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
            const SizedBox(height: AuroraSpacing.sm),
            StatsGrid(activity: activity),
            const SizedBox(height: AuroraSpacing.lg),
            Text('Splits 1km',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
            const SizedBox(height: AuroraSpacing.sm),
            AuroraCard(
              padding: const EdgeInsets.all(AuroraSpacing.sm),
              child: SplitsTable(splits: activity.splits),
            ),
            const SizedBox(height: AuroraSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.ios_share_rounded),
                    label: const Text('Chia sẻ'),
                    onPressed: () async {
                      final bool ok = await ShareCardRenderer.shareBoundary(
                          shareKey, activity);
                      if (!context.mounted) return;
                      if (!ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Không tạo được hình chia sẻ')),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: AuroraSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.file_download_rounded),
                    label: const Text('Xuất GPX'),
                    onPressed: () async {
                      final String gpx = GpxExporter.build(activity);
                      await Share.share(gpx,
                          subject:
                              'runvie_${activity.id}.gpx');
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
