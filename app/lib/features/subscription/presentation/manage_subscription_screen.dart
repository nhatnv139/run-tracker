import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/features/paywall/paywall_placement.dart';
import 'package:runvie/features/paywall/presentation/feature_gate.dart';
import 'package:runvie/features/subscription/subscription_providers.dart';
import 'package:runvie/services/iap_service.dart';
import 'package:runvie/shared/widgets/aurora_button.dart';
import 'package:runvie/shared/widgets/aurora_card.dart';

class ManageSubscriptionScreen extends ConsumerWidget {
  const ManageSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SubscriptionState state = ref.watch(subscriptionControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Quan ly goi')),
      body: ListView(
        padding: const EdgeInsets.all(AuroraSpacing.lg),
        children: <Widget>[
          AuroraCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('Goi hien tai',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: AuroraSpacing.xs),
                Text(
                  _statusLabel(state.status),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                if (state.status == SubscriptionStatus.trial)
                  Padding(
                    padding: const EdgeInsets.only(top: AuroraSpacing.xs),
                    child: Text(
                      'Con ${state.trialDaysLeft} ngay dung thu',
                      style: const TextStyle(
                        color: AuroraColors.coralPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                if (state.snapshot.expiresAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AuroraSpacing.xs),
                    child: Text(
                      state.snapshot.willRenew
                          ? 'Gia han: ${_fmt(state.snapshot.expiresAt!)}'
                          : 'Hieu luc den: ${_fmt(state.snapshot.expiresAt!)}',
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AuroraSpacing.lg),
          if (!state.isPremium)
            AuroraButton(
              label: 'Nang cap Premium',
              variant: AuroraButtonVariant.gradient,
              onPressed: () =>
                  showPaywall(context, PaywallPlacement.featureGate),
            ),
          if (state.isPremium) ...<Widget>[
            AuroraButton(
              label: 'Doi goi',
              variant: AuroraButtonVariant.secondary,
              onPressed: () =>
                  showPaywall(context, PaywallPlacement.featureGate),
            ),
            const SizedBox(height: AuroraSpacing.sm),
            AuroraButton(
              label: 'Huy / quan ly tren store',
              variant: AuroraButtonVariant.ghost,
              onPressed: () => _openStoreSubs(context),
            ),
          ],
          const SizedBox(height: AuroraSpacing.sm),
          AuroraButton(
            label: 'Khoi phuc mua hang',
            variant: AuroraButtonVariant.ghost,
            onPressed: () async {
              final bool ok = await ref
                  .read(subscriptionControllerProvider.notifier)
                  .restore();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(ok ? 'Da khoi phuc' : 'Khong tim thay mua truoc'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _statusLabel(SubscriptionStatus s) {
    switch (s) {
      case SubscriptionStatus.free:
        return 'Free';
      case SubscriptionStatus.trial:
        return 'Premium (dung thu)';
      case SubscriptionStatus.plus:
        return SubscriptionTier.plus.label;
      case SubscriptionStatus.pro:
        return SubscriptionTier.pro.label;
      case SubscriptionStatus.family:
        return SubscriptionTier.family.label;
      case SubscriptionStatus.cancelled:
        return 'Da huy';
    }
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _openStoreSubs(BuildContext context) async {
    final Uri uri = Platform.isIOS
        ? Uri.parse('https://apps.apple.com/account/subscriptions')
        : Uri.parse('https://play.google.com/store/account/subscriptions');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khong mo duoc trang quan ly goi')),
      );
    }
  }
}
