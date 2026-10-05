import 'package:flutter_test/flutter_test.dart';
import 'package:finchat/application/transactions/input_intent.dart';
import 'package:finchat/application/transactions/local_transaction_parser.dart';

void main() {
  test('speech word numbers are transactions and preserve numeric text', () {
    for (final input in ['nasi 10 ribu', 'nasi sepuluh ribu']) {
      expect(detectInputIntent(input), InputIntent.transaction);
      final result = LocalTransactionParser().parse(input).single;
      expect(result.amount, 10000);
      expect(result.categoryId, 'makanan');
    }
    expect(LocalTransactionParser().parse('baju seratus lima puluh ribu').single.amount, 150000);
    expect(LocalTransactionParser().parse('nasi dua puluh lima ribu').single.amount, 25000);
    expect(detectInputIntent('Apakah sepuluh ribu cukup?'), InputIntent.question);
  });
}
