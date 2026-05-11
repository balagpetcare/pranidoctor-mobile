class AiTechnicianApiException implements Exception {
  AiTechnicianApiException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AiTechnicianApiException($code): $message';
}
