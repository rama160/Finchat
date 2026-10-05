import '../../domain/ocr/receipt_ocr.dart';
import '../../domain/parsing/money_amount_parser.dart';
import '../transactions/local_transaction_parser.dart';

class ReceiptTransactionParser {
  const ReceiptTransactionParser();

  List<ParsedTransaction> parse(String rawText, {List<ReceiptOcrLine> lines = const []}) {
    final results = <ParsedTransaction>[];
    String? pendingName;
    final rows = lines.isEmpty ? rawText.split(RegExp(r'\r?\n')) : receiptReadingRows(lines);
    for (final rawLine in rows) {
      final line = rawLine.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (line.isEmpty) continue;
      if (_isNonTransactionLine(line)) { pendingName = null; continue; }
      final matches = MoneyAmountParser.findAll(line);
      // Unformatted prices are common on receipts; keep this receipt-only.
      if (matches.isEmpty) {
        for (final match in RegExp(r'(?<![\w/:-])\d{4,}(?![\w/:-])').allMatches(line)) {
          final amount = MoneyAmountParser.parse(match.group(0)!);
          if (amount != null) matches.add(MoneyMatch(amount: amount, raw: match.group(0)!, start: match.start, end: match.end));
        }
      }
      if (matches.isEmpty) {
        if (RegExp(r'[a-zA-Z]').hasMatch(line) && !RegExp(r'^[\d\W]+$').hasMatch(line)) pendingName = line;
        continue;
      }
      final amountMatch = matches.last;
      final prefix = line.substring(0, amountMatch.start).replaceAll(RegExp(r'^[*•\-]+\s*'), '').trim();
      final quantityLine = RegExp(r'(?:pak|pcs|pc|pck|kg|gram|gr|ltr|liter|buah|unit|qty)\b', caseSensitive: false).hasMatch(prefix)
          || RegExp(r'^[\d\s.,xX*=|]+$').hasMatch(prefix);
      final description = (pendingName != null && (quantityLine || prefix.isEmpty))
          ? pendingName : prefix;
      pendingName = null;
      if (description.isEmpty || amountMatch.amount <= 0 || !RegExp(r'[a-zA-Z]').hasMatch(description)) continue;
      final parsed = LocalTransactionParser().parse('$description Rp ${amountMatch.amount.toStringAsFixed(0)}');
      if (parsed.isEmpty) continue;
      final base = parsed.first;
      results.add(ParsedTransaction(amount: amountMatch.amount, description: description,
        type: base.type, categoryId: base.categoryId, confidence: base.confidence));
    }
    return results;
  }

  bool _isNonTransactionLine(String line) => RegExp(
    r'^[\s|]*(?:total|subtotal|grand total|jumlah bayar|bayar|tunai|cash|kembali|kembalian|diskon|discount|potongan|ppn|pajak|tax|service|change|nomor|no[.,]?|telp|telepon|tanggal|date|jam|time|alamat|jl[.,]?|struk|receipt|invoice|kasir|cashier|pel[.,]?|qty|jumlah item|kredit|kartu|deposit|e-money|barang yang|dikembalikan)\b',
    caseSensitive: false,
  ).hasMatch(line) || RegExp(r'^\+?\d[\d -]{8,}$').hasMatch(line);
}
