import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runvie/core/router/routes.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/features/auth/providers/auth_controller.dart';
import 'package:runvie/features/auth/providers/auth_providers.dart';
import 'package:runvie/shared/widgets/aurora_button.dart';

class EmailOtpVerifyScreen extends ConsumerStatefulWidget {
  const EmailOtpVerifyScreen({super.key});

  @override
  ConsumerState<EmailOtpVerifyScreen> createState() =>
      _EmailOtpVerifyScreenState();
}

class _EmailOtpVerifyScreenState extends ConsumerState<EmailOtpVerifyScreen> {
  final TextEditingController _code = TextEditingController();
  bool _valid = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    final bool ok = v.trim().length == 6;
    if (ok != _valid) setState(() => _valid = ok);
  }

  Future<void> _submit() async {
    final bool ok = await ref
        .read(authControllerProvider.notifier)
        .verifyOtp(_code.text);
    if (ok && mounted) {
      if (ref.read(currentUserProvider) != null) {
        context.go(AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthUiState ui = ref.watch(authControllerProvider);
    final String email = ui.pendingEmail ?? '';

    ref.listen<AuthUiState>(authControllerProvider, (AuthUiState? p, AuthUiState n) {
      if (n.failure != null && (p?.failure != n.failure)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(n.failure!.message)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Xác thực email')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AuroraSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: AuroraSpacing.xl),
              Text(
                'Đã gửi mã xác thực',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AuroraSpacing.sm),
              Text(
                email.isEmpty
                    ? 'Nhập mã 6 chữ số chúng tôi vừa gửi cho bạn.'
                    : 'Đã gửi mã 6 chữ số tới $email.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AuroraSpacing.xl),
              TextField(
                key: const Key('otp.code'),
                controller: _code,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(letterSpacing: 8),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: _onChanged,
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: '------',
                ),
              ),
              const Spacer(),
              AuroraButton(
                key: const Key('otp.verify'),
                label: 'Xác thực',
                variant: AuroraButtonVariant.gradient,
                loading: ui.loading,
                onPressed: (_valid && !ui.loading) ? _submit : null,
              ),
              const SizedBox(height: AuroraSpacing.sm),
              AuroraButton(
                label: 'Đổi email',
                variant: AuroraButtonVariant.ghost,
                onPressed:
                    ui.loading ? null : () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
