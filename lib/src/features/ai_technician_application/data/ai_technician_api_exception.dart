class AiTechnicianApiException implements Exception {
  AiTechnicianApiException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AiTechnicianApiException($code): $message';
}

/// True when [error] is an AI technician API failure caused by Dio cancel /
/// provider dispose — should not surface as a fatal or blocking error during navigation.
bool isCancelledAiTechnicianError(Object error) {
  return error is AiTechnicianApiException && error.code == 'CANCELLED';
}
