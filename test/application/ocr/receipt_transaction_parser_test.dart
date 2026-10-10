import 'package:flutter_test/flutter_test.dart';

import 'package:finchat/application/ocr/receipt_transaction_parser.dart';
import 'package:finchat/domain/ocr/receipt_ocr.dart';

void main() {
  const parser = ReceiptTransactionParser();

  const mahkota = '''
MAHKOTA MART
JL. MERANTI RT.04 BUMI ETAM
0812-5409-3255
No. : 00128150/KSR/UTM/0726
Kasir : MAHKOTA12 - ANITA 21/07/26
Pel. : UMUM/CASH 08:26:21
Pel. : UTM
PIA SARI RASA COKLAT
1 PAK x 20,000 = 20,000
DAIA POWDER DET BAG 800GR VIOLET
1 PCS x 18,800 = 18,800
SLEEK BABY BN & CLEANSER PCH 450ML
1 PCS x 30,259 = 30,259
Qty = 3 69,059
Potongan = 0
Tunai = 70,000
Kredit = 0
Kartu Kredit = 0
Kartu Debit = 0
Deposit = 0
E-Money = 0
Kembali = 941
Barang yang telah dibeli tidak dapat
 dikembalikan kecuali ada perjanjian
''';
  test('Mahkota separate names/prices exclude payment and total rows', () {
    final result = parser.parse(mahkota);
    expect(result.map((item) => item.description), ['PIA SARI RASA COKLAT', 'DAIA POWDER DET BAG 800GR VIOLET', 'SLEEK BABY BN & CLEANSER PCH 450ML']);
    expect(result.map((item) => item.amount), [20000, 18800, 30259]);
    expect(result.fold<double>(0, (sum, item) => sum + item.amount), 69059);
  });
  test('noisy OCR quantity tokens and unit prices retain product names', () {
    final result = parser.parse(mahkota.replaceFirst('1 PAK', 'Pd PAK').replaceFirst('1 PCS', 'jeeuPCS').replaceFirst('30,259 =', 'B07259%—'));
    expect(result, hasLength(3));
    expect(result.last.amount, 30259);
    expect(result[1].description, 'DAIA POWDER DET BAG 800GR VIOLET');
  });
  test('separate OCR blocks are reordered into rows before associating prices', () {
    ReceiptOcrLine line(String text, double x, double y) => ReceiptOcrLine(text: text, left: x, top: y, right: x + 80, bottom: y + 10);
    final result = parser.parse('wrong block ordering', lines: [
      line('20,000', 400, 20), line('18,800', 400, 60), line('69,059', 400, 80),
      line('PIA SARI RASA COKLAT', 0, 0), line('1 PAK x 20,000 =', 0, 21),
      line('DAIA POWDER DET BAG 800GR VIOLET', 0, 40), line('1 PCS x 18,800 =', 0, 60), line('TOTAL', 0, 80),
    ]);
    expect(result.map((item) => item.amount), [20000, 18800]);
    expect(result[1].description, 'DAIA POWDER DET BAG 800GR VIOLET');
  });
  test('plain receipt prices do not turn unit sizes into prices', () {
    final result = parser.parse('SABUN 800GR\n1 PCS x 18800 = 18800\nTOTAL 18800');
    expect(result.single.description, 'SABUN 800GR');
    expect(result.single.amount, 18800);
  });

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
