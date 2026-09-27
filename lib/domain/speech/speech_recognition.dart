enum SpeechSessionStatus { idle, initializing, ready, listening, stopping, stopped, error }

class SpeechRecognitionResult {
  const SpeechRecognitionResult({
    required this.text,
    required this.isFinal,
    this.confidence,
  });

  final String text;
  final bool isFinal;
  final double? confidence;
}

class SpeechRecognitionError {
  const SpeechRecognitionError({required this.message, this.permanent = false});

  final String message;
  final bool permanent;
}

abstract interface class SpeechRecognitionProvider {
  Future<bool> initialize({
    required void Function(SpeechSessionStatus status) onStatus,
    required void Function(SpeechRecognitionError error) onError,
  });

  Future<void> listen({
    required void Function(SpeechRecognitionResult result) onResult,
    String? localeId,
    Duration? listenFor,
    Duration? pauseFor,
  });

  Future<void> stop();
  Future<void> cancel();
}
