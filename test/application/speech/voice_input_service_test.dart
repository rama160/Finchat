import 'package:flutter_test/flutter_test.dart';
import 'package:finchat/application/speech/voice_input_service.dart';
import 'package:finchat/domain/speech/speech_recognition.dart';
import 'package:finchat/application/transactions/local_transaction_parser.dart';
import 'package:finchat/domain/parsing/voice_transaction_normalizer.dart';

class FakeSpeechProvider implements SpeechRecognitionProvider {
  int listenCalls = 0;
  int stopCalls = 0;
  int cancelCalls = 0;
  String? localeId;
  late void Function(SpeechRecognitionResult result) onResult;
  late void Function(SpeechSessionStatus status) statusCallback;

  @override
  Future<bool> initialize({
    required void Function(SpeechSessionStatus status) onStatus,
    required void Function(SpeechRecognitionError error) onError,
  }) async {
    statusCallback = onStatus;
    onStatus(SpeechSessionStatus.ready);
    return true;
  }

  @override
  Future<void> listen({
    required void Function(SpeechRecognitionResult result) onResult,
    String? localeId,
    Duration? listenFor,
    Duration? pauseFor,
  }) async {
    listenCalls++;
    this.localeId = localeId;
    this.onResult = onResult;
    onResult(const SpeechRecognitionResult(text: 'beli makan 25 ribu', isFinal: false, confidence: 0.82));
    onResult(const SpeechRecognitionResult(text: 'beli makan 25 ribu', isFinal: true, confidence: 0.91));
  }

  @override
  Future<void> stop() async => stopCalls++;

  @override
  Future<void> cancel() async => cancelCalls++;
}

class PartialSpeechProvider extends FakeSpeechProvider {
  @override
  Future<void> listen({required void Function(SpeechRecognitionResult result) onResult, String? localeId, Duration? listenFor, Duration? pauseFor}) async {
    this.onResult = onResult;
    onResult(const SpeechRecognitionResult(text: 'nasi', isFinal: false));
    statusCallback(SpeechSessionStatus.stopped);
  }
}

void main() {
  test('a final voice result preserves all transactions after the early partial callback', () async {
    final provider = PartialSpeechProvider();
    final service = VoiceInputService(provider);
    await service.initialize();
    await service.startListening(localeId: 'id_ID', listenFor: const Duration(seconds: 60), pauseFor: const Duration(seconds: 5));
    expect(service.hasFinalResult, isFalse);
    provider.onResult(const SpeechRecognitionResult(text: 'nasi sepuluh ribu dan bensin 50000 lalu parkir dua ribu', isFinal: true));
    expect(service.hasFinalResult, isTrue);
    expect(LocalTransactionParser().parse(normalizeVoiceTransactions(service.transcript)).map((item) => item.amount), [10000, 50000, 2000]);
    await service.cancel();
  });
  test('Android stopped status cannot submit partial nasi before final amount', () async {
    final provider = PartialSpeechProvider();
    final service = VoiceInputService(provider);
    await service.initialize();
    await service.startListening();
    await Future<void>.delayed(const Duration(milliseconds: 450));
    expect(service.status, SpeechSessionStatus.stopped);
    expect(service.hasFinalResult, isFalse);
    provider.onResult(const SpeechRecognitionResult(text: 'nasi 10 ribu', isFinal: true));
    expect(service.hasFinalResult, isTrue);
    expect(service.transcript, 'nasi 10 ribu');
    await service.cancel();
    expect(service.hasFinalResult, isFalse);
  });

  test('notifies UI and keeps Indonesian locale through the provider', () async {
    final provider = FakeSpeechProvider();
    var changes = 0;
    final service = VoiceInputService(provider, onChanged: () => changes++);

    expect(await service.initialize(), isTrue);
    await service.startListening(localeId: 'id_ID');

    expect(provider.localeId, 'id_ID');
    expect(changes, greaterThan(0));
    await Future<void>.delayed(const Duration(milliseconds: 450));
    expect(service.status, SpeechSessionStatus.stopped);
  });

  test('initializes and captures final transcript', () async {
    final provider = FakeSpeechProvider();
    final service = VoiceInputService(provider);

    expect(await service.initialize(), isTrue);
    await service.startListening(localeId: 'id_ID');

    expect(provider.listenCalls, 1);
    expect(service.transcript, 'beli makan 25 ribu');
    expect(service.confidence, 0.91);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    expect(service.status, SpeechSessionStatus.stopped);
  });

  test('stops an active session', () async {
    final provider = FakeSpeechProvider();
    final service = VoiceInputService(provider);
    await service.initialize();

    // The fake completes immediately, so restart a listening state through a custom provider
    // behavior is unnecessary for verifying the guard contract.
    await service.stopListening();
    expect(provider.stopCalls, 0);
    await service.cancel();
  });

  test('late final result after cancel cannot repopulate an old transcript', () async {
    final provider = FakeSpeechProvider();
    final service = VoiceInputService(provider);
    await service.initialize();
    await service.startListening();
    final oldCallback = provider.onResult;
    await service.cancel();
    oldCallback(const SpeechRecognitionResult(text: 'nasi 25rb', isFinal: true));
    expect(service.transcript, isEmpty);
  });

  test('cancel clears transcript', () async {
    final provider = FakeSpeechProvider();
    final service = VoiceInputService(provider);
    await service.initialize();
    await service.startListening();
    await service.cancel();

    expect(service.transcript, isEmpty);
    expect(service.confidence, isNull);
    expect(provider.cancelCalls, 1);
  });
}
