import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_api_exception.dart';

/// Maps thrown errors to Bengali title + body for dashboard error UI.
({String title, String message}) aiTechnicianDashboardErrorPresentation(
  Object error,
) {
  if (error is AiTechnicianApiException) {
    final code = error.code;
    String title;
    switch (code) {
      case 'UNAUTHORIZED':
      case 'FORBIDDEN':
      case 'NOT_ALLOWED':
        title = 'প্রবেশ প্রয়োজন';
      case 'TIMEOUT':
      case 'NETWORK':
        title = 'সংযোগ সমস্যা';
      case 'NOT_FOUND':
      case 'NO_PROFILE':
        title = 'তথ্য পাওয়া যায়নি';
      default:
        title = 'লোড করা যায়নি';
    }
    return (title: title, message: error.message);
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
