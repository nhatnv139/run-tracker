import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:runvie/core/router/routes.dart';
import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/features/auth/providers/auth_controller.dart';
import 'package:runvie/features/auth/providers/auth_providers.dart';
import 'package:runvie/features/settings/models/app_settings.dart';
import 'package:runvie/features/settings/presentation/widgets/settings_section.dart';
import 'package:runvie/features/settings/providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppSettings> settingsAsync = ref.watch(appSettingsProvider);
    final AppSettings s = settingsAsync.valueOrNull ?? const AppSettings();
    final AppSettingsNotifier notifier =
        ref.read(appSettingsProvider.notifier);
    final String email =
        ref.watch(currentUserProvider)?.email ?? 'Khách';

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: AuroraSpacing.sm),
          // Giao diện
          SettingsSection(
            title: 'Giao diện',
            children: <Widget>[
              _RadioTile<ThemeMode>(
                title: 'Theo hệ thống',
                value: ThemeMode.system,
                group: s.themeMode,
                onChanged: notifier.setThemeMode,
              ),
              _RadioTile<ThemeMode>(
                title: 'Sáng',
                value: ThemeMode.light,
                group: s.themeMode,
                onChanged: notifier.setThemeMode,
              ),
              _RadioTile<ThemeMode>(
                title: 'Tối',
                value: ThemeMode.dark,
                group: s.themeMode,
                onChanged: notifier.setThemeMode,
              ),
              ListTile(
                title: const Text('Đơn vị'),
                trailing: SegmentedButton<DistanceUnit>(
                  segments: const <ButtonSegment<DistanceUnit>>[
                    ButtonSegment<DistanceUnit>(
                        value: DistanceUnit.km, label: Text('km')),
                    ButtonSegment<DistanceUnit>(
                        value: DistanceUnit.mi, label: Text('mi')),
                  ],
                  selected: <DistanceUnit>{s.unit},
                  showSelectedIcon: false,
                  onSelectionChanged: (Set<DistanceUnit> sel) =>
                      notifier.setUnit(sel.first),
                ),
              ),
            ],
          ),

          // Coach giọng nói
          SettingsSection(
            title: 'Coach giọng nói',
            children: <Widget>[
              SwitchListTile(
                title: const Text('Bật coach giọng nói'),
                subtitle: const Text('Nghe nhắc mỗi km'),
                value: s.voiceCoachEnabled,
                onChanged: notifier.setVoiceCoachEnabled,
              ),
              IgnorePointer(
                ignoring: !s.voiceCoachEnabled,
                child: Opacity(
                  opacity: s.voiceCoachEnabled ? 1 : 0.4,
                  child: Column(
                    children: <Widget>[
                      _RadioTile<VoiceGender>(
                        title: 'Giọng Bắc',
                        value: VoiceGender.bac,
                        group: s.voiceGender,
                        onChanged: notifier.setVoiceGender,
                      ),
                      _RadioTile<VoiceGender>(
                        title: 'Giọng Nam',
                        value: VoiceGender.nam,
                        group: s.voiceGender,
                        onChanged: notifier.setVoiceGender,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Thông báo
          SettingsSection(
            title: 'Thông báo',
            children: <Widget>[
              SwitchListTile(
                title: const Text('Push thông báo'),
                value: s.pushEnabled,
                onChanged: notifier.setPushEnabled,
              ),
              SwitchListTile(
                title: const Text('Nhắc chạy hằng ngày'),
                subtitle: Text(
                  '${s.reminderHour.toString().padLeft(2, '0')}:${s.reminderMinute.toString().padLeft(2, '0')}',
                ),
                value: s.reminderEnabled,
                onChanged: notifier.setReminderEnabled,
              ),
              if (s.reminderEnabled)
                ListTile(
                  title: const Text('Giờ nhắc'),
                  trailing: TextButton(
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                            hour: s.reminderHour, minute: s.reminderMinute),
                      );
                      if (picked != null) {
                        await notifier.setReminderTime(
                            picked.hour, picked.minute);
                      }
                    },
                    child: Text(
                      '${s.reminderHour.toString().padLeft(2, '0')}:${s.reminderMinute.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
            ],
          ),

          // Dữ liệu
          SettingsSection(
            title: 'Dữ liệu',
            children: <Widget>[
              SwitchListTile(
                title: const Text('Sao lưu lên cloud'),
                subtitle: const Text('Đồng bộ buổi chạy sang Supabase'),
                value: s.cloudBackup,
                onChanged: notifier.setCloudBackup,
              ),
              ListTile(
                leading: const Icon(Icons.download_rounded),
                title: const Text('Xuất tất cả buổi chạy (.gpx)'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã đưa vào hàng đợi xuất')),
                  );
                },
              ),
            ],
          ),

          // Tài khoản
          SettingsSection(
            title: 'Tài khoản',
            children: <Widget>[
              ListTile(
                title: const Text('Email'),
                subtitle: Text(email),
              ),
              ListTile(
                leading:
                    const Icon(Icons.logout_rounded, color: AuroraColors.error),
                title: const Text('Đăng xuất',
                    style: TextStyle(color: AuroraColors.error)),
                onTap: () => _confirmSignOut(context, ref),
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever_rounded,
                    color: AuroraColors.error),
                title: const Text('Xóa tài khoản',
                    style: TextStyle(color: AuroraColors.error)),
                onTap: () => _confirmDeleteAccount(context, ref),
              ),
            ],
          ),

          // Về RunVie
          SettingsSection(
            title: 'Về RunVie',
            children: <Widget>[
              const ListTile(
                title: Text('Phiên bản'),
                trailing: Text('0.1.0'),
              ),
              ListTile(
                title: const Text('Điều khoản dịch vụ'),
                trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                onTap: () => _openUrl('https://runvie.app/terms'),
              ),
              ListTile(
                title: const Text('Chính sách bảo mật'),
                trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                onTap: () => _openUrl('https://runvie.app/privacy'),
              ),
              ListTile(
                title: const Text('Chấm sao trên App Store'),
                trailing: const Icon(Icons.star_rounded,
                    color: AuroraColors.warning),
                onTap: () => _openUrl('https://runvie.app/rate'),
              ),
            ],
          ),

          const SizedBox(height: AuroraSpacing.xxxl),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext c) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text(
            'Bạn có thể đăng nhập lại bất kì lúc nào. Dữ liệu trên máy vẫn được giữ.'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Đăng xuất')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(authControllerProvider.notifier).signOut();
      if (context.mounted) context.go(AppRoutes.signIn);
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context, WidgetRef ref) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext c) => AlertDialog(
        title: const Text('Xóa tài khoản vĩnh viễn?'),
        content: const Text(
            'Toàn bộ buổi chạy, huy hiệu và RunCoin của bạn sẽ bị xóa. Thao tác này không thể hoàn tác.'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Hủy')),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            style: FilledButton.styleFrom(backgroundColor: AuroraColors.error),
            child: const Text('Xóa vĩnh viễn'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final bool success =
        await ref.read(authControllerProvider.notifier).deleteAccount();
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yêu cầu xóa đã được gửi')),
      );
      context.go(AppRoutes.signIn);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không xóa được. Thử lại sau.')),
      );
    }
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _RadioTile<T> extends StatelessWidget {
  const _RadioTile({
    required this.title,
    required this.value,
    required this.group,
    required this.onChanged,
  });
  final String title;
  final T value;
  final T group;
  final ValueChanged<T> onChanged;
  @override
  Widget build(BuildContext context) {
    return RadioListTile<T>(
      title: Text(title),
      value: value,
      groupValue: group,
      onChanged: (T? v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
