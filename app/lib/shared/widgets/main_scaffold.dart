import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:runvie/core/router/routes.dart';
import 'package:runvie/core/theme/colors.dart';

/// Bottom-nav shell wrapping the 4 main tabs + central Run button.
class MainScaffold extends StatelessWidget {
  const MainScaffold({required this.child, super.key});

  final Widget child;

  static const List<_TabSpec> _tabs = <_TabSpec>[
    _TabSpec(AppRoutes.home, Icons.home_outlined, Icons.home_rounded, 'Trang chủ'),
    _TabSpec(AppRoutes.activity, Icons.show_chart_outlined,
        Icons.show_chart_rounded, 'Hoạt động'),
    _TabSpec(AppRoutes.plan, Icons.event_note_outlined,
        Icons.event_note_rounded, 'Kế hoạch'),
    _TabSpec(AppRoutes.profile, Icons.person_outline_rounded,
        Icons.person_rounded, 'Cá nhân'),
  ];

  int _currentIndex(BuildContext context) {
    final String loc = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _tabs.length; i++) {
      if (loc.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final int idx = _currentIndex(context);
    return Scaffold(
      body: child,
      floatingActionButton: FloatingActionButton.large(
        heroTag: 'run-fab',
        backgroundColor: AuroraColors.coralPrimary,
        shape: const CircleBorder(),
        onPressed: () => context.push(AppRoutes.run),
        child: const Icon(Icons.play_arrow_rounded,
            size: 40, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _tabItem(context, 0, idx),
            _tabItem(context, 1, idx),
            const SizedBox(width: 56),
            _tabItem(context, 2, idx),
            _tabItem(context, 3, idx),
          ],
        ),
      ),
    );
  }

  Widget _tabItem(BuildContext context, int i, int current) {
    final _TabSpec t = _tabs[i];
    final bool active = i == current;
    final Color color = active
        ? AuroraColors.coralPrimary
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return IconButton(
      onPressed: () => context.go(t.path),
      icon: Icon(active ? t.iconActive : t.icon, color: color),
      tooltip: t.label,
    );
  }
}

class _TabSpec {
  const _TabSpec(this.path, this.icon, this.iconActive, this.label);
  final String path;
  final IconData icon;
  final IconData iconActive;
  final String label;
}
