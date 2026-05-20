import 'package:flutter/material.dart';

import 'package:runvie/core/theme/spacing.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hoạt động')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(AuroraSpacing.xl),
          child: Text(
            'Lịch sử buổi chạy của bạn sẽ hiển thị ở đây.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
