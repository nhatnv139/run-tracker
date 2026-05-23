import 'package:flutter/material.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';

enum AuroraButtonVariant { primary, secondary, ghost, gradient }

class AuroraButton extends StatelessWidget {
  const AuroraButton({
    required this.label,
    required this.onPressed,
    this.variant = AuroraButtonVariant.primary,
    this.icon,
    this.expand = true,
    this.loading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AuroraButtonVariant variant;
  final IconData? icon;
  final bool expand;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final Widget content = loading
        ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 20),
                const SizedBox(width: AuroraSpacing.sm),
              ],
              Text(label),
            ],
          );

    switch (variant) {
      case AuroraButtonVariant.primary:
        return FilledButton(
          onPressed: loading ? null : onPressed,
          child: content,
        );
      case AuroraButtonVariant.secondary:
        return OutlinedButton(
          onPressed: loading ? null : onPressed,
          child: content,
        );
      case AuroraButtonVariant.ghost:
        return TextButton(
          onPressed: loading ? null : onPressed,
          child: content,
        );
      case AuroraButtonVariant.gradient:
        final bool disabled = loading || onPressed == null;
        return Opacity(
          opacity: disabled ? 0.45 : 1,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: disabled ? null : onPressed,
              borderRadius: BorderRadius.circular(AuroraSpacing.radiusLg),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: AuroraColors.auroraLinear,
                  borderRadius: BorderRadius.circular(AuroraSpacing.radiusLg),
                ),
                height: AuroraSpacing.primaryButtonHeight,
                width: expand ? double.infinity : null,
                child: DefaultTextStyle.merge(
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                  child: Center(child: content),
                ),
              ),
            ),
          ),
        );
    }
  }
}
