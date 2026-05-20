import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/data/models/coin_transaction.dart';
import 'package:runvie/data/repositories/coin_repository.dart';
import 'package:runvie/features/coins/coin_providers.dart';
import 'package:runvie/features/coins/presentation/marketplace_screen.dart';
import 'package:runvie/features/coins/presentation/transaction_history_screen.dart';
import 'package:runvie/shared/widgets/aurora_card.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CoinWalletState s = ref.watch(coinWalletControllerProvider);
    final CoinEarnCalculator calc = ref.watch(coinEarnCalculatorProvider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vi RunCoin'),
          bottom: const TabBar(
            tabs: <Tab>[
              Tab(text: 'Kiem coin'),
              Tab(text: 'Doi voucher'),
            ],
          ),
        ),
        body: Column(
          children: <Widget>[
            _BalanceHero(balance: s.balance, earnedToday: s.earnedToday, calc: calc),
            const SizedBox(height: AuroraSpacing.sm),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  _EarnRulesTab(
                    calc: calc,
                    recent: s.recent.take(8).toList(),
                    onSeeAll: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const TransactionHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  const MarketplaceScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceHero extends StatelessWidget {
  const _BalanceHero({
    required this.balance,
    required this.earnedToday,
    required this.calc,
  });

  final int balance;
  final int earnedToday;
  final CoinEarnCalculator calc;

  @override
  Widget build(BuildContext context) {
    final NumberFormat fmt = NumberFormat.decimalPattern('vi');
    final int capLeft = (calc.dailyCap - earnedToday).clamp(0, calc.dailyCap);
    return Container(
      margin: const EdgeInsets.all(AuroraSpacing.lg),
      padding: const EdgeInsets.all(AuroraSpacing.lg),
      decoration: BoxDecoration(
        gradient: AuroraColors.auroraLinear,
        borderRadius: BorderRadius.circular(AuroraSpacing.radiusXl),
      ),
      child: Column(
        children: <Widget>[
          const Text(
            'So du',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: AuroraSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const Icon(Icons.monetization_on_rounded,
                  color: Colors.white, size: 36),
              const SizedBox(width: AuroraSpacing.sm),
              Text(
                fmt.format(balance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AuroraSpacing.sm),
          Text(
            'Hom nay: +$earnedToday coin (con $capLeft trong cap ${calc.dailyCap})',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _EarnRulesTab extends StatelessWidget {
  const _EarnRulesTab({
    required this.calc,
    required this.recent,
    required this.onSeeAll,
  });

  final CoinEarnCalculator calc;
  final List<CoinTransaction> recent;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AuroraSpacing.lg),
      children: <Widget>[
        Text('Luat kiem coin',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AuroraSpacing.sm),
        AuroraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _RuleLine(
                icon: Icons.directions_run_rounded,
                title: 'Chay 1km',
                value: '${calc.minCoinPerKm}-${calc.baseCoinPerKm} coin',
                subtitle:
                    'Decay theo level. Cap ${calc.dailyCap} coin/ngay tu chay.',
              ),
              const Divider(),
              const _RuleLine(
                icon: Icons.flag_circle_rounded,
                title: 'Hoan thanh quest',
                value: '20-100 coin',
                subtitle: 'Bonus daily quest va challenge.',
              ),
              const Divider(),
              const _RuleLine(
                icon: Icons.group_add_rounded,
                title: 'Gioi thieu ban',
                value: '200 coin',
                subtitle: 'Sau khi ban moi chay du 5km dau tien.',
              ),
            ],
          ),
        ),
        const SizedBox(height: AuroraSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Giao dich gan day',
                style: Theme.of(context).textTheme.titleMedium),
            TextButton(onPressed: onSeeAll, child: const Text('Xem tat ca')),
          ],
        ),
        const SizedBox(height: AuroraSpacing.xs),
        if (recent.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AuroraSpacing.md),
            child: Text(
              'Chua co giao dich nao. Hay chay buoi dau de kiem coin!',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          )
        else
          ...recent.map((CoinTransaction t) => _TxnRow(txn: t)),
      ],
    );
  }
}

class _RuleLine extends StatelessWidget {
  const _RuleLine({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AuroraSpacing.xs),
      child: Row(
        children: <Widget>[
          Icon(icon, color: AuroraColors.coralPrimary),
          const SizedBox(width: AuroraSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                Text(subtitle,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AuroraColors.coralPrimary,
                    fontWeight: FontWeight.w800,
                  )),
        ],
      ),
    );
  }
}

class _TxnRow extends StatelessWidget {
  const _TxnRow({required this.txn});
  final CoinTransaction txn;

  @override
  Widget build(BuildContext context) {
    final bool earn = txn.amount >= 0;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor:
            (earn ? AuroraColors.mintSecondary : AuroraColors.coralPrimary)
                .withValues(alpha: 0.15),
        child: Icon(
          earn ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
          color: earn ? AuroraColors.mintSecondary : AuroraColors.coralPrimary,
        ),
      ),
      title: Text(txn.reason.labelVi),
      subtitle: Text(txn.note ?? ''),
      trailing: Text(
        '${earn ? '+' : ''}${txn.amount}',
        style: TextStyle(
          color: earn ? AuroraColors.mintSecondary : AuroraColors.coralPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      ),
    );
  }
}
