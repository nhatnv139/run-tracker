import 'package:flutter/material.dart';

import 'package:runvie/core/theme/spacing.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kế hoạch')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(AuroraSpacing.xl),
          child: Text(
            'Kế hoạch luyện 5K / 10K / Half sắp ra mắt.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
