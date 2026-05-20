import 'package:flutter/foundation.dart';

/// Badge category — 9 buckets covering the full collection.
enum BadgeCategory {
  distance,
  streak,
  time,
  weather,
  social,
  seasonal,
  hidden,
  pace,
  quirky,
}

extension BadgeCategoryX on BadgeCategory {
  String get labelVi {
    switch (this) {
      case BadgeCategory.distance:
        return 'Quang duong';
      case BadgeCategory.streak:
        return 'Chuoi ngay';
      case BadgeCategory.time:
        return 'Khung gio';
      case BadgeCategory.weather:
        return 'Thoi tiet';
      case BadgeCategory.social:
        return 'Cong dong';
      case BadgeCategory.seasonal:
        return 'Mua le';
      case BadgeCategory.hidden:
        return 'Bi mat';
      case BadgeCategory.pace:
        return 'Toc do';
      case BadgeCategory.quirky:
        return 'Doc la';
    }
  }

  String get labelEn {
    switch (this) {
      case BadgeCategory.distance:
        return 'Distance';
      case BadgeCategory.streak:
        return 'Streak';
      case BadgeCategory.time:
        return 'Time';
      case BadgeCategory.weather:
        return 'Weather';
      case BadgeCategory.social:
        return 'Social';
      case BadgeCategory.seasonal:
        return 'Seasonal';
      case BadgeCategory.hidden:
        return 'Hidden';
      case BadgeCategory.pace:
        return 'Pace';
      case BadgeCategory.quirky:
        return 'Quirky';
    }
  }
}

/// Tier — bronze/silver/gold progressive within a single badge family.
enum BadgeTier { bronze, silver, gold }

extension BadgeTierX on BadgeTier {
  String get label {
    switch (this) {
      case BadgeTier.bronze:
        return 'Bronze';
      case BadgeTier.silver:
        return 'Silver';
      case BadgeTier.gold:
        return 'Gold';
    }
  }
}

/// Criteria type — interpreter key used by [BadgeCriteriaEvaluator].
enum BadgeCriteriaType {
  /// `value` km in a single run.
  distanceSingleKm,

  /// `value` km lifetime.
  distanceTotalKm,

  /// `value` consecutive days streak.
  streakDays,

  /// Run started between [hourStart, hourEnd) — `value` runs total.
  timeOfDay,

  /// Pace <= `value` seconds per km on a single-run >= 5K.
  paceSub5K,

  /// Negative split single run.
  negativeSplit,

  /// Hidden trigger — distance hits an exact value like 3.14km / 4.20km.
  exactDistance,

  /// Comeback King — rebuild a broken streak.
  comebackKing,

  /// Custom — evaluated server-side only.
  custom,
}

@immutable
class BadgeModel {
  const BadgeModel({
    required this.id,
    required this.slug,
    required this.nameVi,
    required this.nameEn,
    required this.descriptionVi,
    required this.descriptionEn,
    required this.category,
    required this.tier,
    required this.criteriaType,
    required this.criteriaValue,
    this.criteriaHourStart,
    this.criteriaHourEnd,
    this.iconAsset,
    this.isHidden = false,
    this.coinReward = 0,
  });

  final String id;
  final String slug;
  final String nameVi;
  final String nameEn;
  final String descriptionVi;
  final String descriptionEn;
  final BadgeCategory category;
  final BadgeTier tier;
  final BadgeCriteriaType criteriaType;

  /// Generic numeric target (km, days, seconds depending on [criteriaType]).
  final double criteriaValue;

  /// For [BadgeCriteriaType.timeOfDay] — inclusive start hour (0-23).
  final int? criteriaHourStart;

  /// For [BadgeCriteriaType.timeOfDay] — exclusive end hour (0-23).
  final int? criteriaHourEnd;

  /// Optional asset name for the badge icon (svg/png in assets/badges/).
  final String? iconAsset;

  /// Hidden badges display as `?` in the gallery until earned.
  final bool isHidden;

  /// RunCoin reward minted when the badge is unlocked.
  final int coinReward;

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      nameVi: json['name_vi'] as String,
      nameEn: json['name_en'] as String,
      descriptionVi: (json['description_vi'] as String?) ?? '',
      descriptionEn: (json['description_en'] as String?) ?? '',
      category: BadgeCategory.values.firstWhere(
        (BadgeCategory c) => c.name == (json['category'] as String),
        orElse: () => BadgeCategory.quirky,
      ),
      tier: BadgeTier.values.firstWhere(
        (BadgeTier t) => t.name == ((json['tier'] as String?) ?? 'bronze'),
        orElse: () => BadgeTier.bronze,
      ),
      criteriaType: BadgeCriteriaType.values.firstWhere(
        (BadgeCriteriaType c) => c.name == (json['criteria_type'] as String),
        orElse: () => BadgeCriteriaType.custom,
      ),
      criteriaValue: ((json['criteria_value'] as num?) ?? 0).toDouble(),
      criteriaHourStart: (json['criteria_hour_start'] as num?)?.toInt(),
      criteriaHourEnd: (json['criteria_hour_end'] as num?)?.toInt(),
      iconAsset: json['icon_asset'] as String?,
      isHidden: (json['is_hidden'] as bool?) ?? false,
      coinReward: ((json['coin_reward'] as num?) ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'slug': slug,
        'name_vi': nameVi,
        'name_en': nameEn,
        'description_vi': descriptionVi,
        'description_en': descriptionEn,
        'category': category.name,
        'tier': tier.name,
        'criteria_type': criteriaType.name,
        'criteria_value': criteriaValue,
        if (criteriaHourStart != null)
          'criteria_hour_start': criteriaHourStart,
        if (criteriaHourEnd != null) 'criteria_hour_end': criteriaHourEnd,
        if (iconAsset != null) 'icon_asset': iconAsset,
        'is_hidden': isHidden,
        'coin_reward': coinReward,
      };
}

/// User-owned badge — represents a row in `user_badges`.
@immutable
class UserBadge {
  const UserBadge({
    required this.badgeId,
    required this.userId,
    required this.earnedAt,
    this.activityId,
  });

  final String badgeId;
  final String userId;
  final DateTime earnedAt;
  final String? activityId;

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    return UserBadge(
      badgeId: json['badge_id'] as String,
      userId: json['user_id'] as String,
      earnedAt: DateTime.parse(json['earned_at'] as String),
      activityId: json['activity_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'badge_id': badgeId,
        'user_id': userId,
        'earned_at': earnedAt.toIso8601String(),
        if (activityId != null) 'activity_id': activityId,
      };
}

/// Composite view used by the gallery — badge plus optional earned date and
/// progress fraction (0..1) used to drive the per-badge progress bar.
@immutable
class BadgeWithStatus {
  const BadgeWithStatus({
    required this.badge,
    required this.earned,
    this.earnedAt,
    this.progress = 0,
  });

  final BadgeModel badge;
  final bool earned;
  final DateTime? earnedAt;
  final double progress; // 0..1
}
