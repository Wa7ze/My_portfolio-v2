/// Sliding-window rate limiter for empty clicks: 8 clicks within 2.5s trips
/// a mock 429.
class RateLimiter {
  final List<int> _timestamps = [];

  static const maxClicks = 8;
  static const window = Duration(milliseconds: 2500);

  /// Registers a click now and returns false if this click exceeds the
  /// limit (the caller should treat it as a 429).
  bool registerClick() {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    _timestamps.removeWhere((t) => nowMs - t > window.inMilliseconds);
    _timestamps.add(nowMs);
    return _timestamps.length <= maxClicks;
  }
}
