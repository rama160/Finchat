import 'package:finchat/domain/speech/speech_recognition.dart';

class VoiceInputService {
  VoiceInputService(this._provider);

  final SpeechRecognitionProvider _provider;

  SpeechSessionStatus _status = SpeechSessionStatus.idle;
  String _transcript = '';
  double? _confidence;

  SpeechSessionStatus get status => _status;
  String get transcript => _transcript;
  double? get confidence => _confidence;
  bool get isListening => _status == SpeechSessionStatus.listening;

  Future<bool> initialize() async {
    _status = SpeechSessionStatus.initializing;
    final available = await _provider.initialize(
      onStatus: (status) => _status = status,
      onError: (error) => _status = SpeechSessionStatus.error,
    );
    if (!available) {
      _status = SpeechSessionStatus.error;
      return false;
    }
    _status = SpeechSessionStatus.ready;
    return true;
  }

  Future<void> startListening({
    String? localeId,
    Duration? listenFor,
    Duration? pauseFor,
  }) async {
    if (_status != SpeechSessionStatus.ready &&
        _status != SpeechSessionStatus.stopped) {
      throw StateError('Speech recognition is not ready.');
    }

    _transcript = '';
    _confidence = null;
    _status = SpeechSessionStatus.listening;

    await _provider.listen(
      localeId: localeId,
      listenFor: listenFor,
      pauseFor: pauseFor,
      onResult: (result) {
        _transcript = result.text.trim();
        _confidence = result.confidence;
        if (result.isFinal) {
          _status = SpeechSessionStatus.stopped;
        }
      },
    );
  }

  Future<void> stopListening() async {
    if (!isListening) return;
    _status = SpeechSessionStatus.stopping;
    await _provider.stop();
    _status = SpeechSessionStatus.stopped;
  }

  Future<void> cancel() async {
    await _provider.cancel();
    _transcript = '';
    _confidence = null;
    _status = SpeechSessionStatus.stopped;
  }
}
