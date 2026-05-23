import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runvie/core/router/routes.dart';
import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/data/models/user_profile.dart';
import 'package:runvie/features/auth/providers/auth_providers.dart';
import 'package:runvie/features/profile/providers/user_profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<UserProfile?> profileAsync =
        ref.watch(userProfileProvider);
    final String? email = ref.watch(currentUserProvider)?.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cá nhân'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Cài đặt',
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AuroraSpacing.lg),
        children: <Widget>[
          _Header(
            displayName: profileAsync.valueOrNull?.displayName ??
                (email?.split('@').first ?? 'RunVie User'),
            level: profileAsync.valueOrNull?.level ?? 'beginner',
            onEdit: () => context.push(AppRoutes.editProfile),
          ),
          const SizedBox(height: AuroraSpacing.xl),
          _MenuTile(
            icon: Icons.emoji_events_rounded,
            color: AuroraColors.coralPrimary,
            title: 'Huy hiệu',
            onTap: () => context.push(AppRoutes.badges),
          ),
          _MenuTile(
            icon: Icons.local_fire_department_rounded,
            color: AuroraColors.warning,
            title: 'Streak',
            onTap: () => context.push(AppRoutes.streak),
          ),
          _MenuTile(
            icon: Icons.account_balance_wallet_rounded,
            color: AuroraColors.mintSecondary,
            title: 'RunCoin Ví',
            onTap: () => context.push(AppRoutes.wallet),
          ),
          _MenuTile(
            icon: Icons.group_rounded,
            color: AuroraColors.lavenderTertiary,
            title: 'Bạn bè',
            onTap: () => context.push(AppRoutes.social),
          ),
          _MenuTile(
            icon: Icons.workspace_premium_rounded,
            color: AuroraColors.lavenderTertiary,
            title: 'Quản lý gói Plus / Pro',
            onTap: () => context.push(AppRoutes.manageSubscription),
          ),
          const Divider(height: AuroraSpacing.xxl),
          _MenuTile(
            icon: Icons.settings_rounded,
            color: Colors.grey,
            title: 'Cài đặt',
            onTap: () => context.push(AppRoutes.settings),
          ),
          _MenuTile(
            icon: Icons.edit_rounded,
            color: Colors.grey,
            title: 'Chỉnh sửa hồ sơ',
            onTap: () => context.push(AppRoutes.editProfile),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.displayName,
    required this.level,
    required this.onEdit,
  });
  final String displayName;
  final String level;
  final VoidCallback onEdit;

  String _levelLabel(String key) {
    switch (key) {
      case 'beginner':
        return 'Người mới';
      case 'intermediate':
        return 'Trung cấp';
      case 'advanced':
        return 'Nâng cao';
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AuroraColors.auroraLinear,
          ),
          child: const Icon(Icons.person_rounded, size: 40, color: Colors.white),
        ),
        const SizedBox(width: AuroraSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(displayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      )),
              const SizedBox(height: 2),
              Text(_levelLabel(level),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AuroraColors.coralPrimary,
                      )),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit_rounded),
          onPressed: onEdit,
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
