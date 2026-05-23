import 'package:flutter/material.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AuroraSpacing.lg,
            AuroraSpacing.md,
            AuroraSpacing.lg,
            AuroraSpacing.xs,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AuroraColors.coralPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AuroraSpacing.lg),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AuroraSpacing.radiusLg),
          ),
          child: Column(
            children: <Widget>[
              for (int i = 0; i < children.length; i++) ...<Widget>[
                children[i],
                if (i < children.length - 1)
                  const Divider(height: 1, indent: AuroraSpacing.lg),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
