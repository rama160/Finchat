import 'package:flutter_test/flutter_test.dart';

import 'package:finchat/application/ocr/receipt_transaction_parser.dart';

void main() {
  const parser = ReceiptTransactionParser();

  test('extracts multiple receipt line items and ignores totals', () {
    final result = parser.parse('''
TOKO MAJU
Nasi Goreng       25.000
Bensin            50.000
Subtotal          75.000
TOTAL             75.000
Tunai             100.000
Kembalian         25.000
''');

    expect(result, hasLength(2));
    expect(result[0].description, 'Nasi Goreng');
    expect(result[0].amount, 25000);
    expect(result[1].description, 'Bensin');
    expect(result[1].amount, 50000);
  });

  test('uses the last amount on a quantity line as the transaction amount', () {
    final result = parser.parse('Kopi 2 x 15.000 30.000');

    expect(result, hasLength(1));
    expect(result.single.description, 'Kopi 2 x 15.000');
    expect(result.single.amount, 30000);
  });

  test('returns empty for text without money amounts', () {
    expect(parser.parse('TOKO MAJU\nTerima kasih'), isEmpty);
  });
}
