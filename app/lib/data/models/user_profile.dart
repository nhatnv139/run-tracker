import 'package:flutter/foundation.dart';

/// Profile row stored in Supabase `profiles` table.
///
/// Hand-rolled immutable model mirroring a Freezed data class (copyWith,
/// value-equality, JSON round-trip). Kept hand-written to avoid the
/// build_runner step at install time.
@immutable
class UserProfile {
  const UserProfile({
    required this.id,
    this.email,
    this.displayName,
    this.avatarUrl,
    this.goal,
    this.level,
    this.weightKg,
    this.heightCm,
    this.age,
    this.gender,
    this.locale = 'vi',
    this.onboarded = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Same as the auth user id (uuid).
  final String id;
  final String? email;
  final String? displayName;
  final String? avatarUrl;

  /// One of `RunGoal.name` values from onboarding (e.g. `loseWeight`).
  final String? goal;

  /// One of `RunLevel.name` values from onboarding (e.g. `beginner`).
  final String? level;

  final double? weightKg;
  final double? heightCm;
  final int? age;

  /// One of `Gender.name` values: `male`, `female`, `other`.
  final String? gender;

  final String locale;
  final bool onboarded;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? goal,
    String? level,
    double? weightKg,
    double? heightCm,
    int? age,
    String? gender,
    String? locale,
    bool? onboarded,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      goal: goal ?? this.goal,
      level: level ?? this.level,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      locale: locale ?? this.locale,
      onboarded: onboarded ?? this.onboarded,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        if (email != null) 'email': email,
        if (displayName != null) 'display_name': displayName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (goal != null) 'goal': goal,
        if (level != null) 'level': level,
        if (weightKg != null) 'weight_kg': weightKg,
        if (heightCm != null) 'height_cm': heightCm,
        if (age != null) 'age': age,
        if (gender != null) 'gender': gender,
        'locale': locale,
        'onboarded': onboarded,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      goal: json['goal'] as String?,
      level: json['level'] as String?,
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      locale: (json['locale'] as String?) ?? 'vi',
      onboarded: (json['onboarded'] as bool?) ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.id == id &&
        other.email == email &&
        other.displayName == displayName &&
        other.avatarUrl == avatarUrl &&
        other.goal == goal &&
        other.level == level &&
        other.weightKg == weightKg &&
        other.heightCm == heightCm &&
        other.age == age &&
        other.gender == gender &&
        other.locale == locale &&
        other.onboarded == onboarded &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        email,
        displayName,
        avatarUrl,
        goal,
        level,
        weightKg,
        heightCm,
        age,
        gender,
        locale,
        onboarded,
        createdAt,
        updatedAt,
      );

  @override
  String toString() =>
      'UserProfile(id: $id, email: $email, onboarded: $onboarded, '
      'goal: $goal, level: $level)';
}
