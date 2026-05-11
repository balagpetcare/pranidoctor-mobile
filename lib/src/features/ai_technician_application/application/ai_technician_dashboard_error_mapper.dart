import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_api_exception.dart';

/// Maps thrown errors to Bengali title + body for dashboard error UI.
({String title, String message}) aiTechnicianDashboardErrorPresentation(
  Object error,
) {
  if (error is AiTechnicianApiException) {
    final code = error.code;
    switch (code) {
      case 'UNAUTHORIZED':
        return (
          title: 'প্রবেশ প্রয়োজন',
          message:
              'লগইন প্রয়োজন বা সেশন শেষ হয়েছে। আবার লগইন করুন।',
        );
      case 'FORBIDDEN':
      case 'NOT_ALLOWED':
        return (
          title: 'অনুমতি নেই',
          message: 'এই ড্যাশবোর্ড দেখার অনুমতি নেই।',
        );
      case 'TIMEOUT':
      case 'NETWORK':
        return (
          title: 'সংযোগ সমস্যা',
          message: error.message,
        );
      case 'CANCELLED':
        return (
          title: 'ড্যাশবোর্ড লোড হচ্ছে',
          message: error.message,
        );
      case 'NOT_FOUND':
      case 'NO_PROFILE':
        return (
          title: 'তথ্য পাওয়া যায়নি',
          message: error.message,
        );
      default:
        return (title: 'লোড করা যায়নি', message: error.message);
    }
  }

  final s = error.toString().toLowerCase();
  if (s.contains('socketexception') ||
      s.contains('network') ||
      s.contains('failed host lookup')) {
    return (
      title: 'সংযোগ সমস্যা',
      message:
          'ইন্টারনেট সংযোগ পরীক্ষা করে আবার চেষ্টা করুন। ডেটা বা ওয়াই-ফাই চালু আছে কিনা দেখুন।',
    );
  }

  return (
    title: 'লোড করা যায়নি',
    message: 'ড্যাশবোর্ড তথ্য আনতে সমস্যা হয়েছে। একটু পরে আবার চেষ্টা করুন।',
  );
}
