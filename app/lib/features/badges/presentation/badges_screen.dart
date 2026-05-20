import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/data/models/badge.dart';
import 'package:runvie/features/badges/badge_providers.dart';
import 'package:runvie/features/badges/presentation/badge_detail_modal.dart';

class BadgesScreen extends ConsumerStatefulWidget {
  const BadgesScreen({super.key});

  @override
  ConsumerState<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends ConsumerState<BadgesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: BadgeCategory.values.length, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<BadgeModel>> catalogAsync =
        ref.watch(badgeCatalogProvider);
    final AsyncValue<List<UserBadge>> earnedAsync =
        ref.watch(earnedBadgesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Huy hieu'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabs: <Tab>[
            for (final BadgeCategory c in BadgeCategory.values)
              Tab(text: c.labelVi),
          ],
        ),
      ),
      body: catalogAsync.when(
        data: (List<BadgeModel> catalog) {
          final Set<String> earnedIds = earnedAsync
              .maybeWhen(
                data: (List<UserBadge> list) =>
                    list.map((UserBadge b) => b.badgeId).toSet(),
                orElse: () => const <String>{},
              )
              .cast<String>();
          return TabBarView(
            controller: _tab,
            children: <Widget>[
              for (final BadgeCategory c in BadgeCategory.values)
                _CategoryGrid(
                  category: c,
                  catalog:
                      catalog.where((BadgeModel b) => b.category == c).toList(),
                  earnedIds: earnedIds,
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, StackTrace st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AuroraSpacing.xl),
            child: Text('Khong tai duoc huy hieu: $e'),
          ),
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.category,
    required this.catalog,
    required this.earnedIds,
  });

  final BadgeCategory category;
  final List<BadgeModel> catalog;
  final Set<String> earnedIds;

  @override
  Widget build(BuildContext context) {
    if (catalog.isEmpty) {
      return Center(
        child: Text(
          'Chua co huy hieu ${category.labelVi.toLowerCase()}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(AuroraSpacing.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AuroraSpacing.md,
        crossAxisSpacing: AuroraSpacing.md,
        childAspectRatio: 0.78,
      ),
      itemCount: catalog.length,
      itemBuilder: (BuildContext context, int i) {
        final BadgeModel b = catalog[i];
        final bool earned = earnedIds.contains(b.id);
        return _BadgeTile(badge: b, earned: earned);
      },
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge, required this.earned});

  final BadgeModel badge;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    final bool hideName = badge.isHidden && !earned;
    final IconData icon = _iconFor(badge);
    return InkWell(
      onTap: () => showBadgeDetailModal(context: context, badge: badge, earned: earned),
      borderRadius: BorderRadius.circular(AuroraSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AuroraSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AuroraSpacing.radiusLg),
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: earned
                ? AuroraColors.coralPrimary.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ColorFiltered(
              colorFilter: earned
                  ? const ColorFilter.mode(
                      Colors.transparent, BlendMode.multiply)
                  : const ColorFilter.matrix(<double>[
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0, 0, 0, 1, 0,
                    ]),
              child: Icon(
                hideName ? Icons.help_outline_rounded : icon,
                size: 56,
                color: earned
                    ? AuroraColors.coralPrimary
                    : AuroraColors.textTertiaryLight,
              ),
            ),
            const SizedBox(height: AuroraSpacing.xs),
            Text(
              hideName ? '???' : badge.nameVi,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: earned ? null : AuroraColors.textTertiaryLight,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(BadgeModel badge) {
    switch (badge.category) {
      case BadgeCategory.distance:
        return Icons.route_rounded;
      case BadgeCategory.streak:
        return Icons.local_fire_department_rounded;
      case BadgeCategory.time:
        return Icons.access_time_filled_rounded;
      case BadgeCategory.weather:
        return Icons.thunderstorm_rounded;
      case BadgeCategory.social:
        return Icons.group_rounded;
      case BadgeCategory.seasonal:
        return Icons.celebration_rounded;
      case BadgeCategory.hidden:
        return Icons.auto_awesome_rounded;
      case BadgeCategory.pace:
        return Icons.speed_rounded;
      case BadgeCategory.quirky:
        return Icons.emoji_events_rounded;
    }
  }
}
