class TechnicianApiException implements Exception {
  TechnicianApiException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}
