/// Shared Bengali copy for customer-visible network failures (no secrets).
abstract final class NetworkMessages {
  /// Shown when the app cannot reach the API (timeouts, DNS, offline, etc.).
  static const String bnServerUnreachable =
      'সার্ভারের সাথে সংযোগ করা যাচ্ছে না। ইন্টারনেট সংযোগ পরীক্ষা করুন।';

  /// Connect/send/receive timeout — distinct copy from generic unreachable.
  static const String bnConnectionTimeout =
      'সার্ভারের সাথে সংযোগে সময় বেশি লাগছে। আবার চেষ্টা করুন।';

  /// Generic failure when status is unknown or unmapped.
  static const String bnGenericRequestFailed =
      'অনুরোধ সম্পূর্ণ করা যায়নি। কিছুক্ষণ পরে আবার চেষ্টা করুন।';

  /// REST / mobile route missing or wrong base URL (often 404).
  static const String bnEndpointNotFound =
      'এই সেবাটি এখন সাময়িকভাবে চালু নেই বা ঠিকানা ভুল। পরে আবার চেষ্টা করুন।';

  /// Server-side errors (5xx).
  static const String bnServerError =
      'সার্ভারে সমস্যা হয়েছে। কিছুক্ষণ পরে আবার চেষ্টা করুন।';

  /// OTP send generic failure (when envelope absent).
  static const String bnOtpSendFailed =
      'OTP পাঠানো যায়নি। অনুগ্রহ করে আবার চেষ্টা করুন।';

  /// OTP verify generic failure (when envelope absent).
  static const String bnOtpVerifyFailed =
      'যাচাইকরণ সম্পূর্ণ করা যায়নি। কোড ও নম্বর পরীক্ষা করে আবার চেষ্টা করুন।';
}
