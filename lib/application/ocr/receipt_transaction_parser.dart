import '../../domain/parsing/money_amount_parser.dart';
import '../transactions/local_transaction_parser.dart';

class ReceiptTransactionParser {
  const ReceiptTransactionParser();

  List<ParsedTransaction> parse(String rawText) {
    final results = <ParsedTransaction>[];
    for (final rawLine in rawText.split(RegExp(r'\r?\n'))) {
      final line = rawLine.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (line.isEmpty || _isNonTransactionLine(line)) continue;

      final matches = MoneyAmountParser.findAll(line);
      if (matches.isEmpty) continue;

      final amountMatch = matches.last;
      final description = line
          .substring(0, amountMatch.start)
          .replaceAll(RegExp(r'^[*•\-]+\s*'), '')
          .replaceAll(RegExp(r'\b(?:qty|jumlah)\s*[:x]?\s*\d+[,.]?\d*\s*$', caseSensitive: false), '')
          .trim();
      if (description.isEmpty) continue;

      final parsed = LocalTransactionParser().parse('$description ${amountMatch.raw}');
      if (parsed.isEmpty) continue;
      final base = parsed.first;
      results.add(
        ParsedTransaction(
          amount: amountMatch.amount,
          description: description,
          type: base.type,
          categoryId: base.categoryId,
          confidence: base.confidence,
        ),
      );
    }
    return results;
  }

  bool _isNonTransactionLine(String line) {
    final normalized = line.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    return RegExp(
      r'^(?:total|subtotal|grand total|total bayar|total pembayaran|jumlah bayar|bayar|tunai|cash|kembali|kembalian|diskon|discount|ppn|pajak|tax|service|change|nomor|no\.?|telp|telepon|tanggal|date|jam|time|alamat|struk|receipt|invoice|kasir|cashier)\b',
      caseSensitive: false,
    ).hasMatch(normalized);
  }
}
