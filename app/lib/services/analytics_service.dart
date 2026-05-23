import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lightweight analytics facade.
///
/// Today this is a zero-dependency stub:
///  - in debug mode events are echoed via [debugPrint] so devs can inspect
///    the funnel
///  - in release mode all methods are no-ops
///
/// When PostHog (or any other vendor) is added later, swap the body of these
/// methods to forward the payload — call sites stay unchanged.
class AnalyticsService {
  AnalyticsService();

  static const String _tag = '[analytics]';

  String? _userId;
  final Map<String, Object?> _superProperties = <String, Object?>{};

  Future<void> init({String? userId}) async {
    _userId = userId;
    _log('init', <String, Object?>{'userId': userId});
  }

  Future<void> identify(
    String userId, {
    Map<String, Object?>? properties,
  }) async {
    _userId = userId;
    _log('identify', <String, Object?>{
      'userId': userId,
      if (properties != null) ...properties,
    });
  }

  Future<void> setSuperProperty(String key, Object? value) async {
    if (value == null) {
      _superProperties.remove(key);
    } else {
      _superProperties[key] = value;
    }
  }

  Future<void> track(
    String event, {
    Map<String, Object?>? properties,
  }) async {
    _log('track:$event', <String, Object?>{
      ..._superProperties,
      if (properties != null) ...properties,
    });
  }

  Future<void> screen(
    String name, {
    Map<String, Object?>? properties,
  }) async {
    _log('screen:$name', <String, Object?>{
      ..._superProperties,
      if (properties != null) ...properties,
    });
  }

  Future<void> reset() async {
    _userId = null;
    _superProperties.clear();
    _log('reset', null);
  }

  void _log(String label, Map<String, Object?>? props) {
    if (!kDebugMode) return;
    final StringBuffer buf = StringBuffer('$_tag $label');
    if (_userId != null) buf.write(' user=$_userId');
    if (props != null && props.isNotEmpty) {
      buf.write(' ');
      buf.write(props);
    }
    debugPrint(buf.toString());
  }
}

final Provider<AnalyticsService> analyticsProvider =
    Provider<AnalyticsService>((Ref ref) => AnalyticsService());
