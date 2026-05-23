import 'package:flutter/material.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';

class RpePicker extends StatelessWidget {
  const RpePicker({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final int? value;
  final ValueChanged<int> onChanged;

  static const List<Color> _colors = <Color>[
    Color(0xFF22C55E), Color(0xFF34D399), Color(0xFF4FE6C7),
    Color(0xFFA3E635), Color(0xFFFBBF24), Color(0xFFF59E0B),
    Color(0xFFF97316), Color(0xFFEF4444), Color(0xFFDC2626), Color(0xFF991B1B),
  ];

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Bạn cảm thấy thế nào?',
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AuroraSpacing.xs),
        Text('Chấm độ gắng sức từ 1 (rất dễ) đến 10 (cực kì khó)',
            style: text.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                )),
        const SizedBox(height: AuroraSpacing.md),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints c) {
            final double cellSize = ((c.maxWidth - 9 * 4) / 10).clamp(24, 56).toDouble();
            return Wrap(
              spacing: 4,
              runSpacing: 4,
              children: <Widget>[
                for (int i = 1; i <= 10; i++)
                  GestureDetector(
                    onTap: () => onChanged(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: cellSize,
                      height: cellSize,
                      decoration: BoxDecoration(
                        color: _colors[i - 1].withValues(
                            alpha: value == i ? 1 : 0.25),
                        borderRadius:
                            BorderRadius.circular(AuroraSpacing.radiusMd),
                        border: value == i
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                        boxShadow: value == i
                            ? <BoxShadow>[
                                BoxShadow(
                                  color: _colors[i - 1].withValues(alpha: 0.6),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$i',
                        style: TextStyle(
                          color: value == i ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: AuroraSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Rất dễ',
                style: text.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline)),
            Text('Cực kì khó',
                style: text.labelSmall?.copyWith(color: AuroraColors.error)),
          ],
        ),
      ],
    );
  }
}
