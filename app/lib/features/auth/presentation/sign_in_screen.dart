import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runvie/core/router/routes.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/features/auth/auth_exception.dart';
import 'package:runvie/features/auth/providers/auth_controller.dart';
import 'package:runvie/features/auth/providers/auth_providers.dart';
import 'package:runvie/shared/widgets/aurora_button.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  Future<void> _afterAuth(BuildContext context, WidgetRef ref) async {
    if (ref.read(currentUserProvider) != null && context.mounted) {
      context.go(AppRoutes.home);
    }
  }

  void _showError(BuildContext context, AuthFailure? f) {
    if (f == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(f.message)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthUiState ui = ref.watch(authControllerProvider);
    final AuthController ctrl = ref.read(authControllerProvider.notifier);
    final bool showApple = ref.read(authRepositoryProvider).isApplePlatform;

    ref.listen<AuthUiState>(authControllerProvider, (AuthUiState? p, AuthUiState n) {
      if (n.failure != null && (p?.failure != n.failure)) {
        _showError(context, n.failure);
      }
    });

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AuroraSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: AuroraSpacing.xxl),
              Text('Đăng nhập',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AuroraSpacing.sm),
              Text(
                'Đồng bộ dữ liệu chạy bộ trên mọi thiết bị.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              AuroraButton(
                label: 'Tiếp tục với Google',
                icon: Icons.g_mobiledata_rounded,
                variant: AuroraButtonVariant.secondary,
                loading: ui.loading,
                onPressed: ui.loading
                    ? null
                    : () async {
                        final bool ok = await ctrl.signInWithGoogle();
                        if (ok) await _afterAuth(context, ref);
                      },
              ),
              if (showApple) ...<Widget>[
                const SizedBox(height: AuroraSpacing.md),
                AuroraButton(
                  label: 'Tiếp tục với Apple',
                  icon: Icons.apple_rounded,
                  variant: AuroraButtonVariant.secondary,
                  loading: ui.loading,
                  onPressed: ui.loading
                      ? null
                      : () async {
                          final bool ok = await ctrl.signInWithApple();
                          if (ok) await _afterAuth(context, ref);
                        },
                ),
              ],
              const SizedBox(height: AuroraSpacing.md),
              AuroraButton(
                key: const Key('signin.email'),
                label: 'Tiếp tục với Email',
                icon: Icons.mail_outline_rounded,
                variant: AuroraButtonVariant.ghost,
                onPressed: ui.loading
                    ? null
                    : () => context.push(AppRoutes.emailOtp),
              ),
              const SizedBox(height: AuroraSpacing.sm),
              AuroraButton(
                key: const Key('signin.guest'),
                label: 'Dùng thử không cần đăng ký',
                variant: AuroraButtonVariant.ghost,
                onPressed: ui.loading
                    ? null
                    : () async {
                        final bool ok = await ctrl.signInAnonymously();
                        if (ok) await _afterAuth(context, ref);
                      },
              ),
              const SizedBox(height: AuroraSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
