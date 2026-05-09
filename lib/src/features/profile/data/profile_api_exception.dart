class ProfileApiException implements Exception {
  ProfileApiException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}
