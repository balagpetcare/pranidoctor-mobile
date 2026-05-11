/// Exponential backoff for transient sync failures (capped).
abstract final class SyncBackoff {
  static const int maxRetries = 12;

  static Duration delayForAttemptIndex(int zeroBasedRetryCount) {
    final i = zeroBasedRetryCount.clamp(0, maxRetries);
    final seconds = (2 * (1 << i)).clamp(2, 300);
    return Duration(seconds: seconds);
  }

  static DateTime nextAttemptAfter({
    required DateTime nowUtc,
    required int zeroBasedRetryCount,
  }) {
    return nowUtc.add(delayForAttemptIndex(zeroBasedRetryCount));
  }
}
