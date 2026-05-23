import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sentry-shaped facade. Stub today: debug-only console output, no-op in
/// release. Drop in `sentry_flutter` later by wiring its API inside these
/// methods — call sites stay unchanged.
class ErrorReportingService {
  ErrorReportingService();

  static const String _tag = '[errors]';

  String? _userId;
  String? _email;

  Future<void> init() async {
    _log('init', null);
  }

  Future<void> captureException(
    Object error, {
    StackTrace? stack,
    Map<String, Object?>? context,
  }) async {
    if (kDebugMode) {
      debugPrint('$_tag exception: $error');
      if (context != null && context.isNotEmpty) {
        debugPrint('$_tag context: $context');
      }
      if (stack != null) {
        debugPrint('$_tag stack:\n$stack');
      }
    }
  }

  Future<void> captureMessage(
    String message, {
    Map<String, Object?>? context,
  }) async {
    if (kDebugMode) {
      debugPrint('$_tag message: $message ${context ?? ''}');
    }
  }

  Future<void> setUser({String? id, String? email}) async {
    _userId = id;
    _email = email;
    _log('setUser', <String, Object?>{'id': id, 'email': email});
  }

  Future<void> clearUser() async {
    _userId = null;
    _email = null;
    _log('clearUser', null);
  }

  void _log(String label, Map<String, Object?>? props) {
    if (!kDebugMode) return;
    final StringBuffer buf = StringBuffer('$_tag $label');
    if (_userId != null) buf.write(' user=$_userId');
    if (_email != null) buf.write(' email=$_email');
    if (props != null && props.isNotEmpty) {
      buf.write(' ');
      buf.write(props);
    }
    debugPrint(buf.toString());
  }
}

final Provider<ErrorReportingService> errorReportingProvider =
    Provider<ErrorReportingService>((Ref ref) => ErrorReportingService());
