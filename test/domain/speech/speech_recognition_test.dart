import 'package:flutter_test/flutter_test.dart';
import 'package:finchat/domain/speech/speech_recognition.dart';

void main() {
  test('speech result preserves transcript, final flag and confidence', () {
    const result = SpeechRecognitionResult(
      text: 'bayar listrik 300 ribu',
      isFinal: true,
      confidence: 0.94,
    );

    expect(result.text, 'bayar listrik 300 ribu');
    expect(result.isFinal, isTrue);
    expect(result.confidence, 0.94);
  });
}
