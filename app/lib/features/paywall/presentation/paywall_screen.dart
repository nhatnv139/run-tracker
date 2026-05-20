import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/features/paywall/paywall_placement.dart';
import 'package:runvie/features/subscription/subscription_providers.dart';
import 'package:runvie/services/iap_service.dart';
import 'package:runvie/shared/widgets/aurora_button.dart';

/// Contextual paywall. Headline/CTA vary by [placement]; the comparison
/// table is shared across placements.
class PaywallContextualScreen extends ConsumerStatefulWidget {
  const PaywallContextualScreen({
    this.placement = PaywallPlacement.onboarding,
    super.key,
  });

  final PaywallPlacement placement;

  @override
  ConsumerState<PaywallContextualScreen> createState() =>
      _PaywallContextualScreenState();
}

class _PaywallContextualScreenState
    extends ConsumerState<PaywallContextualScreen> {
  final PageController _ctrl = PageController(viewportFraction: 0.85);
  int _index = 1; // default to Plus (middle)

  static const List<_TierCardData> _tiers = <_TierCardData>[
    _TierCardData(
      tier: SubscriptionTier.free,
      title: 'Free',
      price: '0 d',
      blurb: 'Tracking co ban + 1 plan',
      features: <String>[
        'GPS tracking',
        'Cong dong va leaderboard',
        '1 plan training',
      ],
      gradient: false,
    ),
    _TierCardData(
      tier: SubscriptionTier.plus,
      title: 'Plus',
      price: '49.000 d/thang',
      blurb: 'HLV AI tieng Viet',
      features: <String>[
        'AI Coach giong noi tieng Viet',
        '3 plan tuy chinh',
        'Xuat GPX/FIT',
        'Khong quang cao',
      ],
      gradient: true,
    ),
    _TierCardData(
      tier: SubscriptionTier.pro,
      title: 'Pro',
      price: '99.000 d/thang',
      blurb: 'Phan tich nang cao + VR',
      features: <String>[
        'Tat ca cua Plus',
        'Phan tich HR zone',
        'Virtual race medal',
        'Goi y dinh duong',
      ],
      gradient: true,
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SubscriptionState sub = ref.watch(subscriptionControllerProvider);
    final AsyncValue<List<IapPackage>> offeringsAsync =
        ref.watch(iapOfferingsProvider);
    final PaywallPlacement placement = widget.placement;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Color(0xFFFFEDE5),
                      Color(0xFFE9E1FF),
                      Color(0xFFD8FBF0),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
                const SizedBox(height: AuroraSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AuroraSpacing.xl),
                  child: Column(
                    children: <Widget>[
                      Text(
                        placement.headlineVi,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: AuroraSpacing.xs),
                      Text(
                        placement.subheadVi,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AuroraSpacing.lg),
                SizedBox(
                  height: 360,
                  child: PageView.builder(
                    controller: _ctrl,
                    itemCount: _tiers.length,
                    onPageChanged: (int i) => setState(() => _index = i),
                    itemBuilder: (BuildContext context, int i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AuroraSpacing.sm,
                        ),
                        child: _TierCard(
                          data: _tiers[i],
                          selected: i == _index,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AuroraSpacing.md),
                _DotsIndicator(count: _tiers.length, index: _index),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AuroraSpacing.xl,
                  ),
                  child: Column(
                    children: <Widget>[
                      AuroraButton(
                        label: placement.primaryCtaVi,
                        variant: AuroraButtonVariant.gradient,
                        loading: sub.loading,
                        onPressed: offeringsAsync.maybeWhen(
                          data: (List<IapPackage> pkgs) => () => _purchase(
                                context,
                                ref,
                                pkgs,
                                _tiers[_index].tier,
                              ),
                          orElse: () => null,
                        ),
                      ),
                      const SizedBox(height: AuroraSpacing.xs),
                      TextButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: Text(
                          placement.secondaryCtaVi,
                          style: const TextStyle(
                            color: AuroraColors.textTertiaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AuroraSpacing.md),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchase(
    BuildContext context,
    WidgetRef ref,
    List<IapPackage> packages,
    SubscriptionTier tier,
  ) async {
    if (tier == SubscriptionTier.free) {
      Navigator.of(context).maybePop();
      return;
    }
    if (packages.isEmpty) return;
    final IapPackage package = packages.firstWhere(
      (IapPackage p) => p.tier == tier,
      orElse: () => packages.first,
    );
    final bool ok = await ref
        .read(subscriptionControllerProvider.notifier)
        .purchase(package);
    if (!context.mounted) return;
    if (ok) {
      Navigator.of(context).maybePop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mua khong thanh cong, vui long thu lai')),
      );
    }
  }
}

class _TierCardData {
  const _TierCardData({
    required this.tier,
    required this.title,
    required this.price,
    required this.blurb,
    required this.features,
    required this.gradient,
  });
  final SubscriptionTier tier;
  final String title;
  final String price;
  final String blurb;
  final List<String> features;
  final bool gradient;
}

class _TierCard extends StatelessWidget {
  const _TierCard({required this.data, required this.selected});
  final _TierCardData data;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 220),
      scale: selected ? 1.0 : 0.94,
      child: Container(
        padding: const EdgeInsets.all(AuroraSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AuroraSpacing.radiusXl),
          gradient:
              data.gradient && selected ? AuroraColors.auroraLinear : null,
          color: data.gradient && selected
              ? null
              : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: selected
                ? AuroraColors.coralPrimary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              data.title,
              style: TextStyle(
                color: data.gradient && selected ? Colors.white : null,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AuroraSpacing.xs),
            Text(
              data.blurb,
              style: TextStyle(
                color: data.gradient && selected
                    ? Colors.white70
                    : AuroraColors.textTertiaryLight,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: AuroraSpacing.md),
            Text(
              data.price,
              style: TextStyle(
                color: data.gradient && selected ? Colors.white : null,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AuroraSpacing.md),
            ...data.features.map(
              (String f) => Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AuroraSpacing.xs / 2),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: data.gradient && selected
                          ? Colors.white
                          : AuroraColors.mintSecondary,
                    ),
                    const SizedBox(width: AuroraSpacing.xs),
                    Expanded(
                      child: Text(
                        f,
                        style: TextStyle(
                          color:
                              data.gradient && selected ? Colors.white : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int i) {
        final bool active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: active ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: active
                ? AuroraColors.coralPrimary
                : AuroraColors.textTertiaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}
