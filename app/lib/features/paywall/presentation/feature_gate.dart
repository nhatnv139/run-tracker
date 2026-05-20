import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/features/paywall/paywall_placement.dart';
import 'package:runvie/features/paywall/presentation/paywall_screen.dart';
import 'package:runvie/features/subscription/subscription_providers.dart';

/// Wraps a Premium feature. If the user is not premium, taps surface the
/// contextual paywall.
class FeatureGate extends ConsumerWidget {
  const FeatureGate({
    required this.child,
    this.placement = PaywallPlacement.featureGate,
    this.lockedLabel = 'Premium',
    super.key,
  });

  final Widget child;
  final PaywallPlacement placement;
  final String lockedLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isPremium = ref.watch(isPremiumProvider);
    if (isPremium) return child;
    return Stack(
      children: <Widget>[
        AbsorbPointer(
          absorbing: true,
          child: Opacity(opacity: 0.5, child: child),
        ),
        Positioned.fill(
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => showPaywall(context, placement),
                borderRadius:
                    BorderRadius.circular(AuroraSpacing.radiusPill),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AuroraSpacing.md,
                    vertical: AuroraSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    gradient: AuroraColors.auroraLinear,
                    borderRadius:
                        BorderRadius.circular(AuroraSpacing.radiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(Icons.lock_rounded,
                          size: 16, color: Colors.white),
                      const SizedBox(width: AuroraSpacing.xs),
                      Text(
                        lockedLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> showPaywall(BuildContext context, PaywallPlacement placement) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PaywallContextualScreen(placement: placement),
      fullscreenDialog: true,
    ),
  );
}
