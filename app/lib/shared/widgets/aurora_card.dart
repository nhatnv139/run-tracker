import 'package:flutter/material.dart';

import 'package:runvie/core/theme/spacing.dart';

class AuroraCard extends StatelessWidget {
  const AuroraCard({
    required this.child,
    this.padding = const EdgeInsets.all(AuroraSpacing.lg),
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius =
        BorderRadius.circular(AuroraSpacing.radiusXl);
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
