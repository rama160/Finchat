import 'package:flutter_test/flutter_test.dart';
import 'package:finchat/application/transactions/input_intent.dart';

void main() {
  test('money in questions must never become database transactions', () {
    for (final input in ['Apakah anggaran 2 juta cukup?', 'berapa pengeluaran jika target 500rb', 'Bagaimana menabung 1jt', 'saldo bulan ini', 'jelaskan laporan saya']) {
      expect(detectInputIntent(input), InputIntent.question, reason: input);
    }
  });
  test('retains local multi transaction input and income', () {
    for (final input in ['nasi 25rb dan bensin 50k', 'gaji 5jt', 'pemasukan bonus 500rb']) {
      expect(detectInputIntent(input), InputIntent.transaction, reason: input);
    }
  });
}
