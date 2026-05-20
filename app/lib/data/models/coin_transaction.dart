import 'package:flutter/foundation.dart';

enum CoinTxnDirection { earn, spend }

enum CoinTxnReason {
  // Earn
  runKm,
  questBonus,
  badgeReward,
  referralBonus,
  weeklyLogin,
  // Spend
  voucherRedeem,
  streakFreezeBuy,
  premiumPurchase,
  // Other
  adjustment,
}

extension CoinTxnReasonX on CoinTxnReason {
  CoinTxnDirection get direction {
    switch (this) {
      case CoinTxnReason.runKm:
      case CoinTxnReason.questBonus:
      case CoinTxnReason.badgeReward:
      case CoinTxnReason.referralBonus:
      case CoinTxnReason.weeklyLogin:
        return CoinTxnDirection.earn;
      case CoinTxnReason.voucherRedeem:
      case CoinTxnReason.streakFreezeBuy:
      case CoinTxnReason.premiumPurchase:
        return CoinTxnDirection.spend;
      case CoinTxnReason.adjustment:
        return CoinTxnDirection.earn;
    }
  }

  String get labelVi {
    switch (this) {
      case CoinTxnReason.runKm:
        return 'Chay bo';
      case CoinTxnReason.questBonus:
        return 'Hoan thanh nhiem vu';
      case CoinTxnReason.badgeReward:
        return 'Mo khoa huy hieu';
      case CoinTxnReason.referralBonus:
        return 'Gioi thieu ban';
      case CoinTxnReason.weeklyLogin:
        return 'Diem danh tuan';
      case CoinTxnReason.voucherRedeem:
        return 'Doi voucher';
      case CoinTxnReason.streakFreezeBuy:
        return 'Mua dong bang chuoi';
      case CoinTxnReason.premiumPurchase:
        return 'Mua Premium';
      case CoinTxnReason.adjustment:
        return 'Dieu chinh';
    }
  }
}

@immutable
class CoinTransaction {
  const CoinTransaction({
    required this.id,
    required this.amount,
    required this.reason,
    required this.createdAt,
    required this.balanceAfter,
    this.note,
    this.activityId,
  });

  /// Signed amount — positive for earn, negative for spend.
  final int amount;
  final CoinTxnReason reason;
  final DateTime createdAt;

  /// Running balance immediately after this transaction settled. Lets the
  /// history list render without re-summing the entire ledger.
  final int balanceAfter;
  final String id;
  final String? note;
  final String? activityId;

  CoinTxnDirection get direction =>
      amount >= 0 ? CoinTxnDirection.earn : CoinTxnDirection.spend;

  factory CoinTransaction.fromJson(Map<String, dynamic> json) {
    return CoinTransaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toInt(),
      reason: CoinTxnReason.values.firstWhere(
        (CoinTxnReason r) => r.name == (json['reason'] as String),
        orElse: () => CoinTxnReason.adjustment,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      balanceAfter: (json['balance_after'] as num).toInt(),
      note: json['note'] as String?,
      activityId: json['activity_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'amount': amount,
        'reason': reason.name,
        'created_at': createdAt.toIso8601String(),
        'balance_after': balanceAfter,
        if (note != null) 'note': note,
        if (activityId != null) 'activity_id': activityId,
      };
}

/// Marketplace voucher offering — partner brand voucher purchasable with coin.
@immutable
class VoucherOffer {
  const VoucherOffer({
    required this.id,
    required this.brand,
    required this.title,
    required this.valueVnd,
    required this.coinCost,
    required this.partnerAppUrl,
    this.logoAsset,
    this.stock,
  });

  final String id;
  final String brand; // e.g. "Shopee", "Grab Food", "Highlands"
  final String title; // e.g. "Voucher 50.000d"
  final int valueVnd;
  final int coinCost;
  final String partnerAppUrl;
  final String? logoAsset;
  final int? stock;

  factory VoucherOffer.fromJson(Map<String, dynamic> json) {
    return VoucherOffer(
      id: json['id'] as String,
      brand: json['brand'] as String,
      title: json['title'] as String,
      valueVnd: (json['value_vnd'] as num).toInt(),
      coinCost: (json['coin_cost'] as num).toInt(),
      partnerAppUrl: (json['partner_app_url'] as String?) ?? '',
      logoAsset: json['logo_asset'] as String?,
      stock: (json['stock'] as num?)?.toInt(),
    );
  }
}

/// Outcome of a successful redemption — server returns the actual code.
@immutable
class RedeemedVoucher {
  const RedeemedVoucher({
    required this.code,
    required this.brand,
    required this.expiresAt,
    required this.partnerAppUrl,
  });

  final String code;
  final String brand;
  final DateTime expiresAt;
  final String partnerAppUrl;

  factory RedeemedVoucher.fromJson(Map<String, dynamic> json) {
    return RedeemedVoucher(
      code: json['code'] as String,
      brand: json['brand'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      partnerAppUrl: (json['partner_app_url'] as String?) ?? '',
    );
  }
}
