import 'dart:async';

import 'package:finchat/domain/speech/speech_recognition.dart';
import '../../domain/speech/transcript_buffer.dart';

class VoiceInputService {
  VoiceInputService(this._provider, {this._onChanged});

  final SpeechRecognitionProvider _provider;
  final void Function()? _onChanged;

  SpeechSessionStatus _status = SpeechSessionStatus.idle;
  String _transcript = '';
  int _generation = 0;
  bool _hasFinalResult = false;
  double? _confidence;
  final TranscriptBuffer _buffer = TranscriptBuffer();
  Timer? _settleTimer;

  SpeechSessionStatus get status => _status;
  String get transcript => _transcript;
  double? get confidence => _confidence;
  bool get hasFinalResult => _hasFinalResult;
  bool get isListening => _status == SpeechSessionStatus.listening;

  void _notifyChanged() => _onChanged?.call();

  Future<bool> initialize() async {
    _status = SpeechSessionStatus.initializing;
    _notifyChanged();
    final available = await _provider.initialize(
      onStatus: (status) {
        _status = _settleTimer?.isActive == true && status == SpeechSessionStatus.stopped
            ? SpeechSessionStatus.stopping : status;
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

    final generation = ++_generation;
    _settleTimer?.cancel();
    _buffer.clear();
    _transcript = '';
    _hasFinalResult = false;
    _confidence = null;
    _status = SpeechSessionStatus.listening;
    _notifyChanged();

    await _provider.listen(
      localeId: localeId,
      listenFor: listenFor,
      pauseFor: pauseFor,
      onResult: (result) {
        if (generation != _generation) return;
        _buffer.add(result.text, isFinal: result.isFinal);
        _transcript = _buffer.text;
        _confidence = result.confidence;
        _hasFinalResult = result.isFinal;
        if (result.isFinal) {
          _status = SpeechSessionStatus.stopping;
          _settleTimer?.cancel();
          _settleTimer = Timer(const Duration(milliseconds: 400), () {
            if (generation != _generation) return;
            _status = SpeechSessionStatus.stopped;
            _notifyChanged();
          });
        }
        _notifyChanged();
      },
    );
  }

  Future<void> stopListening() async {
    if (!isListening) return;
    _status = SpeechSessionStatus.stopping;
    _notifyChanged();
    final generation = _generation;
    await _provider.stop();
    // Android may report notListening before delivering the final amount.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (generation != _generation) return;
    _hasFinalResult = _transcript.isNotEmpty;
    _status = SpeechSessionStatus.stopped;
    _notifyChanged();
  }

  Future<void> cancel() async {
    _generation++;
    _settleTimer?.cancel();
    _buffer.clear();
    // Clear before cancel: the plugin may emit a synchronous stopped callback.
    _transcript = '';
    _hasFinalResult = false;
    _confidence = null;
    await _provider.cancel();
    _status = SpeechSessionStatus.stopped;
    _notifyChanged();
  }
}
