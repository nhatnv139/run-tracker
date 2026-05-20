import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:runvie/core/router/routes.dart';
import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cá nhân')),
      body: ListView(
        padding: const EdgeInsets.all(AuroraSpacing.xl),
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AuroraColors.auroraLinear,
                ),
                child: const Icon(Icons.person_rounded,
                    size: 40, color: Colors.white),
              ),
              const SizedBox(width: AuroraSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('RunVie User',
                        style: Theme.of(context).textTheme.titleLarge),
                    Text('Cấp độ 1',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AuroraSpacing.xl),
          ListTile(
            leading:
                const Icon(Icons.emoji_events_rounded, color: AuroraColors.coralPrimary),
            title: const Text('Huy hiệu'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(AppRoutes.badges),
          ),
          ListTile(
            leading: const Icon(Icons.group_rounded,
                color: AuroraColors.mintSecondary),
            title: const Text('Bạn bè'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(AppRoutes.social),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.settings_rounded),
            title: Text('Cài đặt'),
          ),
        ],
      ),
    );
  }
}
