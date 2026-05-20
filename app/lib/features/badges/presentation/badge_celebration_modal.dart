import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/data/models/badge.dart';
import 'package:runvie/features/badges/badge_providers.dart';
import 'package:runvie/shared/widgets/aurora_button.dart';

/// Show a 3-second celebration with a triple-pulse haptic + sound stub.
/// Drain the [BadgeCelebrationQueue] one badge at a time.
class BadgeCelebrationHost extends ConsumerStatefulWidget {
  const BadgeCelebrationHost({required this.child, super.key});
  final Widget child;

  @override
  ConsumerState<BadgeCelebrationHost> createState() =>
      _BadgeCelebrationHostState();
}

class _BadgeCelebrationHostState extends ConsumerState<BadgeCelebrationHost> {
  bool _showing = false;

  Future<void> _drainIfIdle() async {
    if (_showing) return;
    final BadgeModel? next =
        ref.read(badgeCelebrationProvider.notifier).popNext();
    if (next == null) return;
    _showing = true;
    await _showCelebration(next);
    _showing = false;
    // Drain any remaining in queue.
    if (!mounted) return;
    if (ref.read(badgeCelebrationProvider).isNotEmpty) {
      // ignore: use_build_context_synchronously
      await _drainIfIdle();
    }
  }

  Future<void> _showCelebration(BadgeModel badge) async {
    // Triple haptic pulse — rising intensity. Falls back gracefully on
    // platforms that ignore HapticFeedback.
    HapticFeedback.lightImpact();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    HapticFeedback.heavyImpact();
    if (!mounted) return;
    await showDialog<void>(
      // ignore: use_build_context_synchronously
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => _CelebrationDialog(badge: badge),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<BadgeModel>>(badgeCelebrationProvider,
        (List<BadgeModel>? prev, List<BadgeModel> next) {
      if (next.isNotEmpty) _drainIfIdle();
    });
    return widget.child;
  }
}

class _CelebrationDialog extends StatefulWidget {
  const _CelebrationDialog({required this.badge});
  final BadgeModel badge;

  @override
  State<_CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<_CelebrationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _ctrl.forward();
    // Auto-dismiss after 3 seconds — Lottie placeholder.
    Future<void>.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(AuroraSpacing.xl),
        decoration: BoxDecoration(
          gradient: AuroraColors.auroraLinear,
          borderRadius: BorderRadius.circular(AuroraSpacing.radiusXl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'CHUC MUNG!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: AuroraSpacing.md),
            ScaleTransition(
              scale: Tween<double>(begin: 0.6, end: 1.0).animate(
                CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 96,
              ),
            ),
            const SizedBox(height: AuroraSpacing.md),
            Text(
              widget.badge.nameVi,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AuroraSpacing.sm),
            Text(
              widget.badge.descriptionVi,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: AuroraSpacing.lg),
            AuroraButton(
              label: 'Tuyet voi!',
              variant: AuroraButtonVariant.secondary,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}
