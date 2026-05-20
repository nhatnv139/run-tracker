import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runvie/core/router/routes.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/features/onboarding/models/onboarding_state.dart';
import 'package:runvie/features/onboarding/presentation/_onboarding_layout.dart';
import 'package:runvie/features/onboarding/providers/onboarding_provider.dart';
import 'package:runvie/shared/widgets/aurora_button.dart';

class PersonalizeScreen extends ConsumerStatefulWidget {
  const PersonalizeScreen({super.key});

  @override
  ConsumerState<PersonalizeScreen> createState() => _PersonalizeScreenState();
}

class _PersonalizeScreenState extends ConsumerState<PersonalizeScreen> {
  final TextEditingController _weight = TextEditingController();
  final TextEditingController _height = TextEditingController();
  final TextEditingController _age = TextEditingController();
  Gender _gender = Gender.male;

  @override
  void dispose() {
    _weight.dispose();
    _height.dispose();
    _age.dispose();
    super.dispose();
  }

  bool get _valid =>
      double.tryParse(_weight.text) != null &&
      double.tryParse(_height.text) != null &&
      int.tryParse(_age.text) != null;

  void _submit() {
    ref.read(onboardingControllerProvider.notifier).setPersonal(
          weightKg: double.tryParse(_weight.text),
          heightCm: double.tryParse(_height.text),
          age: int.tryParse(_age.text),
          gender: _gender,
        );
    context.push(AppRoutes.onboardingNotification);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      step: 4,
      title: 'Cá nhân hóa cho bạn',
      subtitle: 'Dùng để tính calo chính xác hơn. Không chia sẻ với ai.',
      primary: AuroraButton(
        label: 'Tiếp tục',
        variant: AuroraButtonVariant.gradient,
        onPressed: _valid ? _submit : null,
      ),
      child: ListView(
        children: <Widget>[
          TextField(
            controller: _weight,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: const InputDecoration(
              labelText: 'Cân nặng (kg)',
              hintText: 'VD: 65',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AuroraSpacing.lg),
          TextField(
            controller: _height,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              labelText: 'Chiều cao (cm)',
              hintText: 'VD: 170',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AuroraSpacing.lg),
          TextField(
            controller: _age,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              labelText: 'Tuổi',
              hintText: 'VD: 28',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AuroraSpacing.lg),
          SegmentedButton<Gender>(
            segments: const <ButtonSegment<Gender>>[
              ButtonSegment<Gender>(value: Gender.male, label: Text('Nam')),
              ButtonSegment<Gender>(value: Gender.female, label: Text('Nữ')),
              ButtonSegment<Gender>(value: Gender.other, label: Text('Khác')),
            ],
            selected: <Gender>{_gender},
            onSelectionChanged: (Set<Gender> v) =>
                setState(() => _gender = v.first),
          ),
        ],
      ),
    );
  }
}
