import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' hide ServiceStatus;

import 'package:runvie/features/run/domain/kalman_filter.dart';

/// Reading produced by the filtered location stream.
class FilteredLocationReading {
  const FilteredLocationReading({
    required this.position,
    required this.isFiltered,
  });

  /// Filtered [Position] (Kalman output, raw on first sample).
  final Position position;

  /// `true` if the Kalman filter actually adjusted the raw sample.
  final bool isFiltered;
}

/// Source of GPS fixes — foreground stream + Kalman filter.
///
/// Lifecycle:
///   1. `requestPermissions()` to grab `whenInUse` (and optionally `always`).
///   2. `start()` opens `Geolocator.getPositionStream`.
///   3. Consume `positionStream` (filtered + outlier-rejected).
///   4. `stop()` closes the stream subscription.
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  final KalmanFilter2D _kalman = KalmanFilter2D();

  StreamSubscription<Position>? _sub;
  StreamSubscription<ServiceStatus>? _serviceStatusSub;

  final StreamController<FilteredLocationReading> _filtered =
      StreamController<FilteredLocationReading>.broadcast();
  final StreamController<Position> _raw =
      StreamController<Position>.broadcast();
  final StreamController<bool> _permissionLost =
      StreamController<bool>.broadcast();

  /// Filtered & outlier-rejected positions (one per accepted GPS fix).
  Stream<FilteredLocationReading> get positionStream => _filtered.stream;

  /// Raw GPS positions (no filter). Useful for debug overlays.
  Stream<Position> get rawPositionStream => _raw.stream;

  /// Emits `true` if the user revokes the location permission mid-run, or
  /// if the OS-level location service is switched off.
  Stream<bool> get permissionLostStream => _permissionLost.stream;

  bool get isStreaming => _sub != null;

  /// Request foreground + (optional) background permissions.
  Future<bool> requestPermissions({bool background = false}) async {
    final PermissionStatus location =
        await Permission.locationWhenInUse.request();
    if (!location.isGranted) return false;
    if (background) {
      final PermissionStatus always =
          await Permission.locationAlways.request();
      return always.isGranted;
    }
    return true;
  }

  /// True if at minimum `whenInUse` is currently granted.
  Future<bool> hasForegroundPermission() async {
    final LocationPermission p = await Geolocator.checkPermission();
    return p == LocationPermission.always ||
        p == LocationPermission.whileInUse;
  }

  /// Start streaming high-accuracy positions. Safe to call multiple times.
  Future<void> start() async {
    if (_sub != null) return;
    _kalman.reset();

    const LocationSettings settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
      timeLimit: null,
    );

    _sub = Geolocator.getPositionStream(locationSettings: settings).listen(
      _onPosition,
      onError: (Object e, StackTrace st) {
        _filtered.addError(e, st);
      },
      cancelOnError: false,
    );

    // Permission / service revocation watcher.
    _serviceStatusSub?.cancel();
    _serviceStatusSub = Geolocator.getServiceStatusStream().listen(
      (ServiceStatus status) {
        if (status == ServiceStatus.disabled) {
          if (!_permissionLost.isClosed) _permissionLost.add(true);
        }
      },
    );
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    await _serviceStatusSub?.cancel();
    _serviceStatusSub = null;
  }

  void _onPosition(Position raw) {
    if (!_raw.isClosed) _raw.add(raw);
    final Position? filtered = _kalman.filter(raw);
    if (filtered == null) return; // rejected (accuracy/jump).
    if (!_filtered.isClosed) {
      _filtered.add(
        FilteredLocationReading(
          position: filtered,
          isFiltered: filtered.latitude != raw.latitude ||
              filtered.longitude != raw.longitude,
        ),
      );
    }
  }

  Future<void> dispose() async {
    await stop();
    if (!_filtered.isClosed) await _filtered.close();
    if (!_raw.isClosed) await _raw.close();
    if (!_permissionLost.isClosed) await _permissionLost.close();
  }
}
