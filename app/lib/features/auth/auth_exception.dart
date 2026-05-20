/// Typed auth errors surfaced to UI with Vietnamese-friendly messages.
class AuthFailure implements Exception {
  const AuthFailure(this.code, this.message);

  /// Stable machine-readable code for branching / analytics.
  final String code;

  /// Vietnamese, user-facing message safe to show in UI.
  final String message;

  @override
  String toString() => 'AuthFailure($code): $message';

  static const AuthFailure cancelled = AuthFailure(
    'cancelled',
    'Bạn đã hủy đăng nhập.',
  );

  static const AuthFailure network = AuthFailure(
    'network',
    'Không có kết nối mạng. Vui lòng thử lại.',
  );

  static const AuthFailure invalidOtp = AuthFailure(
    'invalid_otp',
    'Mã xác thực không đúng hoặc đã hết hạn.',
  );

  static const AuthFailure invalidEmail = AuthFailure(
    'invalid_email',
    'Email không hợp lệ.',
  );

  static const AuthFailure providerUnavailable = AuthFailure(
    'provider_unavailable',
    'Không thể kết nối tới nhà cung cấp đăng nhập.',
  );

  static const AuthFailure missingIdToken = AuthFailure(
    'missing_id_token',
    'Không nhận được token định danh từ nhà cung cấp.',
  );

  static const AuthFailure notSignedIn = AuthFailure(
    'not_signed_in',
    'Bạn chưa đăng nhập.',
  );

  static const AuthFailure unknown = AuthFailure(
    'unknown',
    'Đã có lỗi xảy ra. Vui lòng thử lại.',
  );
}
