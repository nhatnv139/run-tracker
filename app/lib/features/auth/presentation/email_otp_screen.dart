import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runvie/core/router/routes.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/features/auth/providers/auth_controller.dart';
import 'package:runvie/shared/widgets/aurora_button.dart';

class EmailOtpScreen extends ConsumerStatefulWidget {
  const EmailOtpScreen({super.key});

  @override
  ConsumerState<EmailOtpScreen> createState() => _EmailOtpScreenState();
}

class _EmailOtpScreenState extends ConsumerState<EmailOtpScreen> {
  final TextEditingController _email = TextEditingController();
  bool _valid = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    final bool ok = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(v.trim());
    if (ok != _valid) setState(() => _valid = ok);
  }

  Future<void> _submit() async {
    final bool ok = await ref
        .read(authControllerProvider.notifier)
        .requestOtp(_email.text);
    if (ok && mounted) {
      context.push(AppRoutes.emailOtpVerify);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthUiState ui = ref.watch(authControllerProvider);

    ref.listen<AuthUiState>(authControllerProvider, (AuthUiState? p, AuthUiState n) {
      if (n.failure != null && (p?.failure != n.failure)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(n.failure!.message)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập bằng Email')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AuroraSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: AuroraSpacing.xl),
              Text(
                'Nhập địa chỉ email',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AuroraSpacing.sm),
              Text(
                'Chúng tôi sẽ gửi mã xác thực 6 chữ số tới email của bạn.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AuroraSpacing.xl),
              TextField(
                key: const Key('otp.email'),
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                onChanged: _onChanged,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'ban@vidu.com',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
              ),
              const Spacer(),
              AuroraButton(
                key: const Key('otp.send'),
                label: 'Gửi mã xác thực',
                variant: AuroraButtonVariant.gradient,
                loading: ui.loading,
                onPressed: (_valid && !ui.loading) ? _submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
