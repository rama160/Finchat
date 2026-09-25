import 'package:flutter_test/flutter_test.dart';
import 'package:finchat/domain/parsing/money_amount_parser.dart';

void main() {
  test('recognizes common Indonesian thousand formats', () {
    expect(MoneyAmountParser.findAll('25 rb').single.amount, 25000);
    expect(MoneyAmountParser.findAll('25 ribu').single.amount, 25000);
    expect(MoneyAmountParser.findAll('25k').single.amount, 25000);
    expect(MoneyAmountParser.findAll('Rp 25.000').single.amount, 25000);
    expect(MoneyAmountParser.findAll('Rp25.000').single.amount, 25000);
  });

  test('recognizes million formats and decimals', () {
    expect(MoneyAmountParser.findAll('1 juta').single.amount, 1000000);
    expect(MoneyAmountParser.findAll('1,5 juta').single.amount, 1500000);
    expect(MoneyAmountParser.findAll('1.5jt').single.amount, 1500000);
    expect(MoneyAmountParser.findAll('2m').single.amount, 2000000);
  });

  test('recognizes multiple amounts in one input', () {
    final values = MoneyAmountParser.findAll('nasi 25 rb dan bensin 50k');
    expect(values.map((e) => e.amount).toList(), [25000, 50000]);
  });

  test('recognizes billion and Indonesian grouped number', () {
    expect(MoneyAmountParser.findAll('Rp 1.250.000').single.amount, 1250000);
    expect(MoneyAmountParser.findAll('2 miliar').single.amount, 2000000000);
  });
}
