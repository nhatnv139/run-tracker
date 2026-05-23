import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runvie/core/router/routes.dart';
import 'package:runvie/core/theme/aurora_theme.dart';
import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/core/theme/typography.dart';
import 'package:runvie/data/models/activity.dart';
import 'package:runvie/features/activity/providers/activity_providers.dart';
import 'package:runvie/features/run/providers/run_session_provider.dart';

Future<void> _finishRun(BuildContext context, WidgetRef ref) async {
  final RunSessionState run = ref.read(runSessionProvider);
  ref.read(runSessionProvider.notifier).stop();
  final Activity saved = await ref.read(activityRepositoryProvider).save(
        Activity(
          id: 0,
          type: ActivityType.run,
          startedAt: DateTime.now().subtract(run.elapsed),
          endedAt: DateTime.now(),
          distanceMeters: run.distanceMeters,
          duration: run.elapsed,
          avgPaceSecPerKm: run.distanceMeters > 0
              ? run.elapsed.inSeconds / (run.distanceMeters / 1000)
              : 0,
          calories: run.calories,
          syncStatus: ActivitySyncStatus.pending,
        ),
      );
  if (!context.mounted) return;
  context.go(AppRoutes.postRunPath(saved.id));
}

class RunScreen extends ConsumerWidget {
  const RunScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final RunSessionState run = ref.watch(runSessionProvider);
    final RunSessionController ctrl = ref.read(runSessionProvider.notifier);

    return Theme(
      data: AuroraTheme.black(),
      child: Scaffold(
        backgroundColor: AuroraColors.bgBlack,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              _TopBar(onClose: () => context.pop()),
              const Spacer(),
              _SwipeMetric(
                metrics: <_Metric>[
                  _Metric(
                    label: 'KM',
                    value: run.distanceKm.toStringAsFixed(2),
                  ),
                  _Metric(label: 'PHÚT', value: run.elapsed.inMinutes.toString()),
                  _Metric(label: 'CALO', value: run.calories.toStringAsFixed(0)),
                ],
              ),
              const SizedBox(height: AuroraSpacing.xxl),
              _SecondaryRow(run: run),
              const Spacer(),
              _Controls(
                state: run,
                controller: ctrl,
                onFinish: () => _finishRun(context, ref),
              ),
              const SizedBox(height: AuroraSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AuroraSpacing.lg,
        vertical: AuroraSpacing.sm,
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.white, size: 32),
          ),
          const Spacer(),
          const _GpsBadge(),
        ],
      ),
    );
  }
}

class _GpsBadge extends StatelessWidget {
  const _GpsBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AuroraSpacing.md,
        vertical: AuroraSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AuroraColors.mintSecondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AuroraSpacing.radiusPill),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.gps_fixed_rounded,
              color: AuroraColors.mintSecondary, size: 14),
          SizedBox(width: 4),
          Text('GPS',
              style: TextStyle(
                color: AuroraColors.mintSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              )),
        ],
      ),
    );
  }
}

class _Metric {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
}

class _SwipeMetric extends StatefulWidget {
  const _SwipeMetric({required this.metrics});
  final List<_Metric> metrics;

  @override
  State<_SwipeMetric> createState() => _SwipeMetricState();
}

class _SwipeMetricState extends State<_SwipeMetric> {
  final PageController _ctrl = PageController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: PageView.builder(
        controller: _ctrl,
        itemCount: widget.metrics.length,
        itemBuilder: (BuildContext ctx, int i) {
          final _Metric m = widget.metrics[i];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                m.value,
                style: AuroraTypography.runDistance(),
              ),
              Text(
                m.label,
                style: const TextStyle(
                  color: Colors.white60,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  fontSize: 14,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SecondaryRow extends StatelessWidget {
  const _SecondaryRow({required this.run});
  final RunSessionState run;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _SecondaryMetric(
          label: 'TỐC ĐỘ',
          value: run.paceFormatted,
        ),
        _SecondaryMetric(
          label: 'THỜI GIAN',
          value: run.elapsedFormatted,
        ),
        const _SecondaryMetric(label: 'NHỊP TIM', value: '--'),
      ],
    );
  }
}

class _SecondaryMetric extends StatelessWidget {
  const _SecondaryMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(value, style: AuroraTypography.runMetric()),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.state,
    required this.controller,
    required this.onFinish,
  });
  final RunSessionState state;
  final RunSessionController controller;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    if (state.status == RunStatus.idle) {
      return _BigButton(
        icon: Icons.play_arrow_rounded,
        color: AuroraColors.coralPrimary,
        onPressed: controller.start,
      );
    }
    if (state.status == RunStatus.running) {
      return _BigButton(
        icon: Icons.pause_rounded,
        color: AuroraColors.coralPrimary,
        onPressed: controller.pause,
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _BigButton(
          icon: Icons.stop_rounded,
          color: AuroraColors.error,
          onPressed: onFinish,
        ),
        const SizedBox(width: AuroraSpacing.xxl),
        _BigButton(
          icon: Icons.play_arrow_rounded,
          color: AuroraColors.mintSecondary,
          onPressed: controller.resume,
        ),
      ],
    );
  }
}

class _BigButton extends StatelessWidget {
  const _BigButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AuroraSpacing.pauseButton,
      height: AuroraSpacing.pauseButton,
      child: Material(
        color: color,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Icon(icon, color: Colors.white, size: 40),
        ),
      ),
    );
  }
}
