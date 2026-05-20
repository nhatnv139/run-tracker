import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/data/models/coin_transaction.dart';
import 'package:runvie/features/coins/coin_providers.dart';
import 'package:runvie/services/supabase_service.dart';
import 'package:runvie/shared/widgets/aurora_button.dart';

class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<VoucherOffer>> async =
        ref.watch(voucherCatalogProvider);
    return async.when(
      data: (List<VoucherOffer> offers) => GridView.builder(
        padding: const EdgeInsets.all(AuroraSpacing.lg),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AuroraSpacing.md,
          crossAxisSpacing: AuroraSpacing.md,
          childAspectRatio: 0.7,
        ),
        itemCount: offers.length,
        itemBuilder: (BuildContext context, int i) =>
            _VoucherCard(offer: offers[i]),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object e, StackTrace st) =>
          Center(child: Text('Khong tai duoc voucher: $e')),
    );
  }
}

class _VoucherCard extends ConsumerWidget {
  const _VoucherCard({required this.offer});
  final VoucherOffer offer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NumberFormat vnd = NumberFormat.decimalPattern('vi');
    return Container(
      padding: const EdgeInsets.all(AuroraSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AuroraSpacing.radiusLg),
        border: Border.all(
          color: AuroraColors.coralPrimary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: AuroraColors.surfaceLightAlt,
              borderRadius: BorderRadius.circular(AuroraSpacing.radiusMd),
            ),
            child: Center(
              child: Text(
                offer.brand,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
          const SizedBox(height: AuroraSpacing.sm),
          Text(
            'Voucher ${vnd.format(offer.valueVnd)} d',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const Spacer(),
          Row(
            children: <Widget>[
              const Icon(Icons.monetization_on_rounded,
                  color: AuroraColors.coralPrimary, size: 16),
              const SizedBox(width: 2),
              Text(
                '${offer.coinCost}',
                style: const TextStyle(
                  color: AuroraColors.coralPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AuroraSpacing.xs),
          AuroraButton(
            label: 'Doi ngay',
            onPressed: () => _confirmRedeem(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRedeem(BuildContext context, WidgetRef ref) async {
    final CoinWalletState s = ref.read(coinWalletControllerProvider);
    if (s.balance < offer.coinCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('So du khong du de doi voucher nay')),
      );
      return;
    }
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text('Doi ${offer.brand}?'),
        content: Text(
          'Tieu ${offer.coinCost} coin de nhan ${offer.title}. So du sau khi doi: ${s.balance - offer.coinCost} coin.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Huy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xac nhan'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final String? uid = SupabaseService.instance.currentUser?.id;
    if (uid == null) return;
    showDialog<void>(
      // ignore: use_build_context_synchronously
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final RedeemedVoucher? v =
          await ref.read(coinWalletControllerProvider.notifier).redeem(
                userId: uid,
                offer: offer,
              );
      if (!context.mounted) return;
      Navigator.of(context).pop();
      if (v != null) {
        // ignore: use_build_context_synchronously
        await _showSuccess(context, v);
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Doi voucher that bai: $e')),
      );
    }
  }

  Future<void> _showSuccess(
    BuildContext context,
    RedeemedVoucher voucher,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Thanh cong!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Brand: ${voucher.brand}'),
            const SizedBox(height: AuroraSpacing.sm),
            SelectableText(
              voucher.code,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: AuroraSpacing.sm),
            Text('HSD: ${voucher.expiresAt.toLocal()}'),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: voucher.code));
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('Da copy ma voucher')),
              );
            },
            child: const Text('Copy'),
          ),
          FilledButton(
            onPressed: () async {
              final Uri uri = Uri.parse(voucher.partnerAppUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Mo app'),
          ),
        ],
      ),
    );
  }
}
