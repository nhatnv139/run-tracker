// Integration test: redeem coins for Shopee voucher.
//
// Verifies that:
//   - Wallet shows balance
//   - User picks a voucher
//   - Backend returns a voucher code
//   - Code is displayed in the success view

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '_helpers/test_app.dart';

abstract class _CoinService {
  Future<int> getBalance();
  Future<String> redeemShopee({required int costCoins});
}

class _MockCoinService extends Mock implements _CoinService {}

class _FakeWallet extends StatefulWidget {
  const _FakeWallet({required this.service});
  final _MockCoinService service;

  @override
  State<_FakeWallet> createState() => _FakeWalletState();
}

class _FakeWalletState extends State<_FakeWallet> {
  int _balance = 0;
  String? _voucher;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final b = await widget.service.getBalance();
    setState(() => _balance = b);
  }

  Future<void> _redeem() async {
    final code = await widget.service.redeemShopee(costCoins: 500);
    setState(() => _voucher = code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('balance:$_balance'),
          ElevatedButton(
            key: const Key('btn_redeem'),
            onPressed: _balance >= 500 ? _redeem : null,
            child: const Text('Redeem Shopee 50K'),
          ),
          if (_voucher != null) Text('voucher:$_voucher'),
        ],
      ),
    );
  }
}

void main() {
  ensureBinding();

  late _MockCoinService service;

  setUp(() {
    service = _MockCoinService();
    when(() => service.getBalance()).thenAnswer((_) async => 1000);
    when(() => service.redeemShopee(costCoins: any(named: 'costCoins')))
        .thenAnswer((_) async => 'SHOPEE-50K-ABCD1234');
  });

  testWidgets('redeem coins shows voucher code', (tester) async {
    await bootRunVie(tester, rootScreen: _FakeWallet(service: service));

    expect(find.text('balance:1000'), findsOneWidget);

    await tester.tap(find.byKey(const Key('btn_redeem')));
    await tester.pumpAndSettle();

    expect(find.text('voucher:SHOPEE-50K-ABCD1234'), findsOneWidget);
    verify(() => service.redeemShopee(costCoins: 500)).called(1);
  });
}
