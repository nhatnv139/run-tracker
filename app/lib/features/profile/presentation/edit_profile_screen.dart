import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/data/models/user_profile.dart';
import 'package:runvie/features/auth/providers/auth_providers.dart';
import 'package:runvie/features/profile/providers/user_profile_provider.dart';
import 'package:runvie/features/settings/models/app_settings.dart';
import 'package:runvie/features/settings/providers/settings_providers.dart';
import 'package:runvie/shared/widgets/aurora_button.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  String? _gender;
  DateTime? _dob;
  double _height = 165;
  double _weight = 60;
  bool _initialized = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
  }

  void _hydrate(UserProfile p) {
    if (_initialized) return;
    _initialized = true;
    _nameCtrl.text = p.displayName ?? '';
    _gender = p.gender;
    _height = p.heightCm ?? 165;
    _weight = p.weightKg ?? 60;
    if (p.age != null) {
      _dob = DateTime(DateTime.now().year - p.age!, 1, 1);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<UserProfile?> profileAsync =
        ref.watch(userProfileProvider);
    final AppSettings settings =
        ref.watch(appSettingsProvider).valueOrNull ?? const AppSettings();
    final AppSettingsNotifier settingsNotifier =
        ref.read(appSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa hồ sơ')),
      body: profileAsync.when(
        data: (UserProfile? p) {
          if (p != null) _hydrate(p);
          return _buildForm(context, settings, settingsNotifier);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text('Lỗi: $e')),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AuroraSpacing.lg),
          child: AuroraButton(
            label: _saving ? 'Đang lưu…' : 'Lưu thay đổi',
            loading: _saving,
            variant: AuroraButtonVariant.gradient,
            onPressed: _saving ? null : _save,
          ),
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    AppSettings settings,
    AppSettingsNotifier settingsNotifier,
  ) {
    return ListView(
      padding: const EdgeInsets.all(AuroraSpacing.lg),
      children: <Widget>[
        Center(
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đổi ảnh — sắp ra mắt')),
              );
            },
            child: const _AvatarPlaceholder(),
          ),
        ),
        const SizedBox(height: AuroraSpacing.xl),
        TextField(
          controller: _nameCtrl,
          maxLength: 30,
          decoration: const InputDecoration(
            labelText: 'Tên hiển thị',
            hintText: 'VD: Nguyễn Vie',
          ),
        ),
        const SizedBox(height: AuroraSpacing.md),
        Text('Giới tính', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AuroraSpacing.xs),
        Wrap(
          spacing: AuroraSpacing.sm,
          children: <Widget>[
            for (final ({String label, String value}) g in const <({String label, String value})>[
              (label: 'Nam', value: 'male'),
              (label: 'Nữ', value: 'female'),
              (label: 'Khác', value: 'other'),
            ])
              ChoiceChip(
                label: Text(g.label),
                selected: _gender == g.value,
                onSelected: (_) => setState(() => _gender = g.value),
              ),
          ],
        ),
        const SizedBox(height: AuroraSpacing.lg),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Ngày sinh'),
          subtitle: Text(_dob == null
              ? 'Chưa đặt'
              : '${_dob!.day}/${_dob!.month}/${_dob!.year}'),
          trailing: const Icon(Icons.calendar_month_rounded),
          onTap: () async {
            final DateTime now = DateTime.now();
            final DateTime initial = _dob ?? DateTime(now.year - 25, 1, 1);
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime(1920),
              lastDate: now,
            );
            if (picked != null) setState(() => _dob = picked);
          },
        ),
        const SizedBox(height: AuroraSpacing.sm),
        _SliderField(
          label: 'Chiều cao',
          value: _height,
          min: 100,
          max: 220,
          step: 1,
          unit: 'cm',
          onChanged: (double v) => setState(() => _height = v),
        ),
        _SliderField(
          label: 'Cân nặng',
          value: _weight,
          min: 30,
          max: 200,
          step: 0.5,
          unit: 'kg',
          fractionDigits: 1,
          onChanged: (double v) => setState(() => _weight = v),
        ),
        const Divider(height: AuroraSpacing.xxl),
        Text('Mục tiêu hằng ngày',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AuroraSpacing.sm),
        _SliderField(
          label: 'Bước chân',
          value: settings.dailyStepGoal.toDouble(),
          min: 3000,
          max: 20000,
          step: 500,
          unit: 'bước',
          fractionDigits: 0,
          onChanged: (double v) => settingsNotifier.setDailyStepGoal(v.round()),
        ),
        _SliderField(
          label: 'Quãng đường',
          value: settings.dailyKmGoal,
          min: 1,
          max: 20,
          step: 0.5,
          unit: 'km',
          fractionDigits: 1,
          onChanged: settingsNotifier.setDailyKmGoal,
        ),
        const SizedBox(height: AuroraSpacing.huge),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final UserProfile? current = ref.read(userProfileProvider).valueOrNull;
      if (current == null) {
        final String? userId = ref.read(currentUserProvider)?.id;
        if (userId == null) {
          throw StateError('Chưa đăng nhập');
        }
        final UserProfile next = UserProfile(
          id: userId,
          displayName: _nameCtrl.text.trim(),
          gender: _gender,
          heightCm: _height,
          weightKg: _weight,
          age: _dob == null ? null : DateTime.now().year - _dob!.year,
          onboarded: true,
        );
        await ref.read(profileRepositoryProvider).upsert(next);
      } else {
        final UserProfile next = current.copyWith(
          displayName: _nameCtrl.text.trim(),
          gender: _gender,
          heightCm: _height,
          weightKg: _weight,
          age: _dob == null ? null : DateTime.now().year - _dob!.year,
        );
        await ref.read(profileRepositoryProvider).upsert(next);
      }
      ref.invalidate(userProfileProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _SliderField extends StatelessWidget {
  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.unit,
    required this.onChanged,
    this.fractionDigits = 0,
  });
  final String label;
  final double value;
  final double min;
  final double max;
  final double step;
  final String unit;
  final int fractionDigits;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final int divisions = ((max - min) / step).round();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AuroraSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(label)),
              Text(
                '${value.toStringAsFixed(fractionDigits)} $unit',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AuroraColors.auroraLinear,
      ),
      child: const Icon(Icons.person_rounded, size: 56, color: Colors.white),
    );
  }
}
