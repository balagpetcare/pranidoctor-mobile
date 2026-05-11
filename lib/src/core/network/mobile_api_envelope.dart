/// Helpers for `{ ok, data?, error? }` mobile JSON responses.
library;

class MobileApiEnvelopeException implements Exception {
  MobileApiEnvelopeException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'MobileApiEnvelopeException($code): $message';
}

Map<String, dynamic> unwrapOkDataMap(dynamic responseData) {
  if (responseData is! Map<String, dynamic>) {
    throw MobileApiEnvelopeException('অপ্রত্যাশিত উত্তর');
  }
  if (responseData['ok'] != true) {
    final err = responseData['error'];
    final msg = err is Map && err['message'] is String
        ? err['message'] as String
        : 'অনুরোধ ব্যর্থ হয়েছে';
    final code = err is Map && err['code'] is String
        ? err['code'] as String
        : null;
    throw MobileApiEnvelopeException(msg, code: code);
  }
  final inner = responseData['data'];
  if (inner is! Map<String, dynamic>) {
    throw MobileApiEnvelopeException('অপ্রত্যাশিত উত্তর');
  }
  return inner;
}
