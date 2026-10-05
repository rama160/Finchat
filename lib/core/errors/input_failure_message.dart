String inputFailureMessage(Object error, String fallback) {
  if (error is FormatException && error.message.length <= 160 && !error.message.contains('\n')) {
    return '$fallback ${error.message}';
  }
  return fallback;
}
