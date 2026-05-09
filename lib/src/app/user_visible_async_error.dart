import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_repository.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/data/technician_api_exception.dart';

/// Bengali message for Riverpod/async errors — uses API exception copy when available,
/// otherwise a generic message (no raw exception types, Dio stack traces, or URLs).
String userVisibleAsyncErrorBn(Object error) {
  if (error is ServiceRequestApiException) return error.message;
  if (error is TechnicianApiException) return error.message;
  return 'ডেটা লোড করা যায়নি। ইন্টারনেট সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।';
}
