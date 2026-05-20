import 'package:flutter/material.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bạn bè')),
      body: const Center(child: Text('Kết nối với bạn bè đang chạy.')),
    );
  }
}
