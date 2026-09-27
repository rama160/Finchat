import 'package:finchat/domain/speech/speech_recognition.dart';

class VoiceInputService {
  VoiceInputService(this._provider, {void Function()? onChanged}) : _onChanged = onChanged;

  final SpeechRecognitionProvider _provider;
  final void Function()? _onChanged;

  SpeechSessionStatus _status = SpeechSessionStatus.idle;
  String _transcript = '';
  double? _confidence;

  SpeechSessionStatus get status => _status;
  String get transcript => _transcript;
  double? get confidence => _confidence;
  bool get isListening => _status == SpeechSessionStatus.listening;

  void _notifyChanged() => _onChanged?.call();

  Future<bool> initialize() async {
    _status = SpeechSessionStatus.initializing;
    _notifyChanged();
    final available = await _provider.initialize(
      onStatus: (status) {
        _status = status;
        _notifyChanged();
      },
      onError: (error) {
        _status = SpeechSessionStatus.error;
        _notifyChanged();
      },
    );
    if (!available) {
      _status = SpeechSessionStatus.error;
      _notifyChanged();
      return false;
    }
    _status = SpeechSessionStatus.ready;
    _notifyChanged();
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
    _notifyChanged();

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
        _notifyChanged();
      },
    );
  }

  Future<void> stopListening() async {
    if (!isListening) return;
    _status = SpeechSessionStatus.stopping;
    _notifyChanged();
    await _provider.stop();
    _status = SpeechSessionStatus.stopped;
    _notifyChanged();
  }

  Future<void> cancel() async {
    await _provider.cancel();
    _transcript = '';
    _confidence = null;
    _status = SpeechSessionStatus.stopped;
    _notifyChanged();
  }
}
