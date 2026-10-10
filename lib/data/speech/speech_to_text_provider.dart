import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:finchat/domain/speech/speech_recognition.dart';

class SpeechToTextProvider implements SpeechRecognitionProvider {
  SpeechToTextProvider([stt.SpeechToText? speech]) : _speech = speech ?? stt.SpeechToText();

  final stt.SpeechToText _speech;

  void Function(SpeechSessionStatus status)? _onStatus;
  void Function(SpeechRecognitionError error)? _onError;

  @override
  Future<bool> initialize({
    required void Function(SpeechSessionStatus status) onStatus,
    required void Function(SpeechRecognitionError error) onError,
  }) async {
    _onStatus = onStatus;
    _onError = onError;
    final available = await _speech.initialize(
      onStatus: _handleStatus,
      onError: (error) {
        _onError?.call(
          SpeechRecognitionError(
            message: error.errorMsg,
            permanent: error.permanent,
          ),
        );
      },
    );
    _onStatus?.call(available ? SpeechSessionStatus.ready : SpeechSessionStatus.error);
    return available;
  }

  void _handleStatus(String status) {
    if (status == 'listening') {
      _onStatus?.call(SpeechSessionStatus.listening);
    } else if (status == 'done' || status == 'notListening') {
      _onStatus?.call(SpeechSessionStatus.stopped);
    }
  }

  @override
  Future<void> listen({
    required void Function(SpeechRecognitionResult result) onResult,
    String? localeId,
    Duration? listenFor,
    Duration? pauseFor,
  }) async {
    await _speech.listen(
      listenOptions: stt.SpeechListenOptions(
        localeId: localeId,
        listenFor: listenFor,
        pauseFor: pauseFor,
        partialResults: true,
        listenMode: stt.ListenMode.dictation,
      ),
      onResult: (result) => onResult(
        SpeechRecognitionResult(
          text: result.recognizedWords,
          isFinal: result.finalResult,
          confidence: result.hasConfidenceRating ? result.confidence : null,
        ),
      ),
    );
  }

  @override
  Future<void> stop() => _speech.stop();

  @override
  Future<void> cancel() => _speech.cancel();
}
