/// Shared Bengali copy for customer-visible network failures (no secrets).
abstract final class NetworkMessages {
  /// Shown when the app cannot reach the API (timeouts, DNS, offline, etc.).
  static const String bnServerUnreachable =
      'সার্ভারের সাথে সংযোগ করা যাচ্ছে না। ইন্টারনেট সংযোগ পরীক্ষা করুন।';
}
