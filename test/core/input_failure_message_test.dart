import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finchat/core/errors/input_failure_message.dart';

void main() {
  test('quota guidance remains visible while unrelated technical errors stay hidden', () {
    const guidance = 'Kuota Voice bulan ini telah digunakan. Pencatatan teks tetap tersedia.';
    expect(inputFailureMessage(const UserFacingException(guidance), 'Mikrofon gagal.'), guidance);
    expect(inputFailureMessage(StateError('technical database detail'), 'Coba lagi.'), 'Coba lagi.');
  });
  test('native stack trace stays out of user messages', () {
    final error = PlatformException(code: 'TextRecognizerError', message: 'NullPointerException\n${List.filled(100, 'at wm1.init(java:62)').join('\n')}');
    expect(inputFailureMessage(error, 'Struk belum dapat dibaca.'), 'Struk belum dapat dibaca.');
    expect(inputFailureMessage(const FormatException('Nominal harus positif.'), 'Input tidak valid.'), contains('Nominal harus positif.'));
  });
}
