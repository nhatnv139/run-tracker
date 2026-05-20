/// Paywall placement context. Each placement shows a slightly different
/// headline / hero so the conversion message matches the moment.
///
/// Conversion-critical: always show the placement-specific benefit first;
/// generic feature comparison comes second.
enum PaywallPlacement {
  /// First-launch onboarding paywall — emphasis on reverse trial.
  onboarding,

  /// Shown after a saved run — emphasis on smart coaching insight teaser.
  postWorkout,

  /// Shown when the user taps a locked Premium feature.
  featureGate,

  /// Shown after a milestone (e.g. 100km lifetime, first marathon).
  milestone,

  /// Shown to lapsed users coming back from a re-engagement push.
  reEngagement,
}

extension PaywallPlacementCopy on PaywallPlacement {
  String get headlineVi {
    switch (this) {
      case PaywallPlacement.onboarding:
        return 'Khoi dau cung HLV AI 14 ngay';
      case PaywallPlacement.postWorkout:
        return 'Phan tich chuyen sau buoi chay vua roi';
      case PaywallPlacement.featureGate:
        return 'Mo khoa tinh nang Premium';
      case PaywallPlacement.milestone:
        return 'Chuc mung cot moc — nhan thuong Premium';
      case PaywallPlacement.reEngagement:
        return 'Quay lai cung uu dai dac biet';
    }
  }

  String get subheadVi {
    switch (this) {
      case PaywallPlacement.onboarding:
        return 'Khong can the. Huy luc nao cung duoc.';
      case PaywallPlacement.postWorkout:
        return 'Xem chi tiet pace, HR zone, goi y phuc hoi.';
      case PaywallPlacement.featureGate:
        return 'Tinh nang nay danh cho hoi vien Plus/Pro.';
      case PaywallPlacement.milestone:
        return 'Tang 14 ngay Premium de mung thanh tich.';
      case PaywallPlacement.reEngagement:
        return 'Giam 30% nam dau khi nang cap hom nay.';
    }
  }

  /// CTA primary label.
  String get primaryCtaVi {
    switch (this) {
      case PaywallPlacement.onboarding:
      case PaywallPlacement.milestone:
        return 'Dung thu mien phi 14 ngay';
      case PaywallPlacement.postWorkout:
      case PaywallPlacement.featureGate:
        return 'Nang cap ngay';
      case PaywallPlacement.reEngagement:
        return 'Nhan uu dai';
    }
  }

  /// Secondary (dismiss) label. Intentionally low-contrast in UI.
  String get secondaryCtaVi {
    switch (this) {
      case PaywallPlacement.onboarding:
        return 'Tiep tuc dung Free';
      case PaywallPlacement.postWorkout:
      case PaywallPlacement.featureGate:
      case PaywallPlacement.milestone:
        return 'De sau';
      case PaywallPlacement.reEngagement:
        return 'Khong, cam on';
    }
  }
}
