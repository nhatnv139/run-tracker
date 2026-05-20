import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/data/models/coin_transaction.dart';
import 'package:runvie/features/coins/coin_providers.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CoinWalletState s = ref.watch(coinWalletControllerProvider);
    final DateFormat fmt = DateFormat('dd/MM HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Lich su giao dich')),
      body: ListView.separated(
        itemCount: s.recent.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (BuildContext context, int i) {
          final CoinTransaction t = s.recent[i];
          final bool earn = t.amount >= 0;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  (earn ? AuroraColors.mintSecondary : AuroraColors.coralPrimary)
                      .withValues(alpha: 0.15),
              child: Icon(
                earn
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: earn
                    ? AuroraColors.mintSecondary
                    : AuroraColors.coralPrimary,
              ),
            ),
            title: Text(t.reason.labelVi),
            subtitle: Text(
              '${fmt.format(t.createdAt.toLocal())} - So du: ${t.balanceAfter}',
            ),
            trailing: Text(
              '${earn ? '+' : ''}${t.amount}',
              style: TextStyle(
                color: earn
                    ? AuroraColors.mintSecondary
                    : AuroraColors.coralPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          );
        },
      ),
    );
  }
}
