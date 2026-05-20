import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

/// Background service wrapper for keeping GPS alive when screen off.
///
/// iOS: relies on `UIBackgroundModes: location` + significant location updates.
/// Android: foreground service with persistent notification.
class BackgroundLocationService {
  BackgroundLocationService._();
  static final BackgroundLocationService instance =
      BackgroundLocationService._();

  static const String _notifChannelId = 'runvie_run_tracking';
  static const String _notifChannelName = 'Theo dõi buổi chạy';

  Future<void> initialize() async {
    final FlutterBackgroundService service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: _notifChannelId,
        initialNotificationTitle: 'RunVie đang theo dõi',
        initialNotificationContent: 'Buổi chạy đang được ghi lại',
        foregroundServiceNotificationId: 9001,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
    );
  }

  Future<void> startTracking() async {
    final FlutterBackgroundService service = FlutterBackgroundService();
    await service.startService();
  }

  Future<void> stopTracking() async {
    final FlutterBackgroundService service = FlutterBackgroundService();
    service.invoke('stopService');
  }
}

@pragma('vm:entry-point')
void _onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((_) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((_) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((_) {
    service.stopSelf();
  });

  // TODO: subscribe to LocationService stream here and persist points.
}

@pragma('vm:entry-point')
Future<bool> _onIosBackground(ServiceInstance service) async {
  return true;
}
