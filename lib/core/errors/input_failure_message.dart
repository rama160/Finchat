/// Only curated application messages may bypass the technical-error sanitizer.
class UserFacingException implements Exception {
  const UserFacingException(this.message);
  final String message;
  @override String toString() => message;
}

String inputFailureMessage(Object error, String fallback) {
  if (error is UserFacingException) return error.message;
  if (error is FormatException && error.message.length <= 160 && !error.message.contains('\n')) {
    return '$fallback ${error.message}';
  }
  return fallback;
}
