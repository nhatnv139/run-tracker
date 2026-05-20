extension DurationFormat on Duration {
  /// Returns mm:ss or h:mm:ss depending on length.
  String get clockFormat {
    final int h = inHours;
    final int m = inMinutes.remainder(60);
    final int s = inSeconds.remainder(60);
    final String mm = m.toString().padLeft(2, '0');
    final String ss = s.toString().padLeft(2, '0');
    if (h > 0) return '$h:$mm:$ss';
    return '$mm:$ss';
  }

  /// Pace formatted as m'ss" per km.
  String get paceFormat {
    final int m = inMinutes;
    final int s = inSeconds.remainder(60);
    return "$m'${s.toString().padLeft(2, '0')}\"";
  }
}
