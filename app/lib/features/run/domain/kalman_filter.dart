import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

/// 2D Kalman filter operating in a local tangent plane (meters from a
/// reference latitude). State vector: [x, y, vx, vy].
///
/// Measurement is GPS position projected to (x, y) — speed comes via
/// finite differences of filtered states.
///
/// Process noise Q ~ 4 m^2/s^2 per axis (running variability).
/// Measurement noise R = accuracy^2 (per axis, from the GPS sensor).
class KalmanFilter2D {
  KalmanFilter2D({
    this.processNoise = 4.0,
    this.maxAccuracyMeters = 50.0,
    this.maxSpeedMps = 8.0,
  });

  /// Sigma^2 for the random-walk velocity model (m^2/s^2).
  final double processNoise;

  /// GPS samples with accuracy above this are rejected outright.
  final double maxAccuracyMeters;

  /// Speed jump (between consecutive filtered samples) above this
  /// rejects the new sample (likely GPS multipath / teleport).
  final double maxSpeedMps;

  // State.
  double? _x;
  double? _y;
  double _vx = 0.0;
  double _vy = 0.0;

  // Covariance matrix P (4x4) — symmetric, stored as 16 doubles.
  final List<double> _P = List<double>.filled(16, 0.0, growable: false);

  // Reference latitude for the local tangent plane (set on first sample).
  double? _refLat;
  double? _refLon;

  DateTime? _lastTimestamp;

  static const double _earthRadius = 6378137.0; // WGS84 semi-major axis.

  /// Returns the filtered [Position], or `null` if the sample was rejected.
  Position? filter(Position raw) {
    if (raw.accuracy > maxAccuracyMeters) return null;

    final DateTime now = raw.timestamp;
    if (_refLat == null || _refLon == null) {
      _refLat = raw.latitude;
      _refLon = raw.longitude;
      _x = 0.0;
      _y = 0.0;
      _vx = 0.0;
      _vy = 0.0;
      _initCovariance(raw.accuracy);
      _lastTimestamp = now;
      return _project(raw, _x!, _y!, 0.0);
    }

    final double dt = math
        .max(0.05, now.difference(_lastTimestamp!).inMilliseconds / 1000.0);

    // 1) Predict.
    _predict(dt);

    // 2) Outlier rejection in observation space.
    final List<double> measured = _toLocal(raw.latitude, raw.longitude);
    final double dx = measured[0] - _x!;
    final double dy = measured[1] - _y!;
    final double distance = math.sqrt(dx * dx + dy * dy);
    final double jumpSpeed = distance / dt;
    if (jumpSpeed > maxSpeedMps) {
      // Discard this measurement but keep the predicted state so the
      // filter does not freeze forever during a tunnel.
      _lastTimestamp = now;
      return null;
    }

    // 3) Update.
    final double r = math.max(1.0, raw.accuracy * raw.accuracy);
    _update(measured[0], measured[1], r);

    _lastTimestamp = now;
    final double speed = math.sqrt(_vx * _vx + _vy * _vy);
    return _project(raw, _x!, _y!, speed);
  }

  // ------------------------------------------------------------------
  //  Local tangent-plane projection (equirectangular — good < 5 km).
  // ------------------------------------------------------------------
  List<double> _toLocal(double lat, double lon) {
    final double latRad = lat * math.pi / 180.0;
    final double refLatRad = _refLat! * math.pi / 180.0;
    final double dLat = (lat - _refLat!) * math.pi / 180.0;
    final double dLon = (lon - _refLon!) * math.pi / 180.0;
    final double x = _earthRadius * dLon * math.cos((refLatRad + latRad) / 2);
    final double y = _earthRadius * dLat;
    return <double>[x, y];
  }

  List<double> _toGeographic(double x, double y) {
    final double refLatRad = _refLat! * math.pi / 180.0;
    final double dLat = y / _earthRadius;
    final double lat = _refLat! + dLat * 180.0 / math.pi;
    final double midLatRad = (refLatRad + lat * math.pi / 180.0) / 2;
    final double dLon = x / (_earthRadius * math.cos(midLatRad));
    final double lon = _refLon! + dLon * 180.0 / math.pi;
    return <double>[lat, lon];
  }

  // ------------------------------------------------------------------
  //  Covariance handling (4x4 row-major).
  // ------------------------------------------------------------------
  void _initCovariance(double accuracy) {
    // Position variance ~ accuracy^2; velocity variance is initially large.
    for (int i = 0; i < 16; i++) {
      _P[i] = 0.0;
    }
    final double r = math.max(1.0, accuracy * accuracy);
    _P[_idx(0, 0)] = r;
    _P[_idx(1, 1)] = r;
    _P[_idx(2, 2)] = 25.0; // 5 m/s std initial.
    _P[_idx(3, 3)] = 25.0;
  }

  static int _idx(int row, int col) => row * 4 + col;

  void _predict(double dt) {
    // x' = x + vx*dt, y' = y + vy*dt, vx, vy unchanged (random-walk velocity).
    _x = _x! + _vx * dt;
    _y = _y! + _vy * dt;

    // P = F P F^T + Q.
    // F = [[1,0,dt,0],[0,1,0,dt],[0,0,1,0],[0,0,0,1]]
    final List<double> Pnew = List<double>.filled(16, 0.0, growable: false);

    // Compute FP first (FP[i,j] = sum_k F[i,k] * P[k,j]).
    final List<double> FP = List<double>.filled(16, 0.0, growable: false);
    for (int j = 0; j < 4; j++) {
      FP[_idx(0, j)] = _P[_idx(0, j)] + dt * _P[_idx(2, j)];
      FP[_idx(1, j)] = _P[_idx(1, j)] + dt * _P[_idx(3, j)];
      FP[_idx(2, j)] = _P[_idx(2, j)];
      FP[_idx(3, j)] = _P[_idx(3, j)];
    }
    // Pnew = FP * F^T.
    for (int i = 0; i < 4; i++) {
      Pnew[_idx(i, 0)] = FP[_idx(i, 0)] + dt * FP[_idx(i, 2)];
      Pnew[_idx(i, 1)] = FP[_idx(i, 1)] + dt * FP[_idx(i, 3)];
      Pnew[_idx(i, 2)] = FP[_idx(i, 2)];
      Pnew[_idx(i, 3)] = FP[_idx(i, 3)];
    }

    // Add Q. For a random-walk velocity model with sigma_a = sqrt(processNoise):
    //   Q = [[dt^4/4, 0, dt^3/2, 0],
    //        [0, dt^4/4, 0, dt^3/2],
    //        [dt^3/2, 0, dt^2, 0],
    //        [0, dt^3/2, 0, dt^2]] * processNoise
    final double dt2 = dt * dt;
    final double dt3 = dt2 * dt;
    final double dt4 = dt3 * dt;
    final double q = processNoise;
    Pnew[_idx(0, 0)] += dt4 / 4.0 * q;
    Pnew[_idx(1, 1)] += dt4 / 4.0 * q;
    Pnew[_idx(2, 2)] += dt2 * q;
    Pnew[_idx(3, 3)] += dt2 * q;
    Pnew[_idx(0, 2)] += dt3 / 2.0 * q;
    Pnew[_idx(2, 0)] += dt3 / 2.0 * q;
    Pnew[_idx(1, 3)] += dt3 / 2.0 * q;
    Pnew[_idx(3, 1)] += dt3 / 2.0 * q;

    for (int i = 0; i < 16; i++) {
      _P[i] = Pnew[i];
    }
  }

  void _update(double zx, double zy, double r) {
    // H = [[1,0,0,0],[0,1,0,0]], R = r * I (per axis independent).
    // Innovation y = z - H x.
    final double yx = zx - _x!;
    final double yy = zy - _y!;

    // S = H P H^T + R, here a 2x2 matrix.
    final double sxx = _P[_idx(0, 0)] + r;
    final double syy = _P[_idx(1, 1)] + r;
    final double sxy = _P[_idx(0, 1)];
    final double det = sxx * syy - sxy * sxy;
    if (det.abs() < 1e-9) return;
    final double invXX = syy / det;
    final double invYY = sxx / det;
    final double invXY = -sxy / det;

    // K = P H^T S^-1, a 4x2 matrix.
    final List<double> K = List<double>.filled(8, 0.0, growable: false);
    for (int i = 0; i < 4; i++) {
      final double phx = _P[_idx(i, 0)];
      final double phy = _P[_idx(i, 1)];
      K[i * 2] = phx * invXX + phy * invXY;
      K[i * 2 + 1] = phx * invXY + phy * invYY;
    }

    // x = x + K y.
    _x = _x! + K[0] * yx + K[1] * yy;
    _y = _y! + K[2] * yx + K[3] * yy;
    _vx = _vx + K[4] * yx + K[5] * yy;
    _vy = _vy + K[6] * yx + K[7] * yy;

    // P = (I - K H) P.
    final List<double> Pnew = List<double>.filled(16, 0.0, growable: false);
    for (int j = 0; j < 4; j++) {
      for (int i = 0; i < 4; i++) {
        double v = _P[_idx(i, j)];
        v -= K[i * 2] * _P[_idx(0, j)];
        v -= K[i * 2 + 1] * _P[_idx(1, j)];
        Pnew[_idx(i, j)] = v;
      }
    }
    for (int i = 0; i < 16; i++) {
      _P[i] = Pnew[i];
    }
  }

  Position _project(Position raw, double x, double y, double speed) {
    final List<double> latLon = _toGeographic(x, y);
    return Position(
      latitude: latLon[0],
      longitude: latLon[1],
      timestamp: raw.timestamp,
      accuracy: raw.accuracy,
      altitude: raw.altitude,
      altitudeAccuracy: raw.altitudeAccuracy,
      heading: raw.heading,
      headingAccuracy: raw.headingAccuracy,
      speed: speed,
      speedAccuracy: raw.speedAccuracy,
    );
  }

  /// Resets the filter state. Call before re-using for a new session.
  void reset() {
    _x = null;
    _y = null;
    _vx = 0.0;
    _vy = 0.0;
    _refLat = null;
    _refLon = null;
    _lastTimestamp = null;
    for (int i = 0; i < 16; i++) {
      _P[i] = 0.0;
    }
  }
}
