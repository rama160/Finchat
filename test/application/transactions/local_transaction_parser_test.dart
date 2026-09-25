import 'package:flutter_test/flutter_test.dart';
import 'package:finchat/application/transactions/local_transaction_parser.dart';

void main() {
  final parser = LocalTransactionParser();

  test('parses one expense with 25 rb', () {
    final result = parser.parse('Beli nasi 25 rb');
    expect(result, hasLength(1));
    expect(result.single.amount, 25000);
    expect(result.single.type, ParsedTransactionType.expense);
    expect(result.single.categoryId, 'makanan');
  });

  test('parses one expense with 25 ribu', () {
    expect(parser.parse('Bayar parkir 25 ribu').single.amount, 25000);
  });

  test('parses one expense with 25k', () {
    expect(parser.parse('Beli bensin 25k').single.amount, 25000);
  });

  test('parses multiple transactions from one text', () {
    final result = parser.parse('Beli nasi 25 rb dan bensin 50k');
    expect(result, hasLength(2));
    expect(result[0].amount, 25000);
    expect(result[0].categoryId, 'makanan');
    expect(result[1].amount, 50000);
    expect(result[1].categoryId, 'transportasi');
  });

  test('parses income using million shorthand', () {
    final result = parser.parse('Gaji bulan ini 7 juta');
    expect(result.single.amount, 7000000);
    expect(result.single.type, ParsedTransactionType.income);
    expect(result.single.categoryId, 'gaji');
  });
}
