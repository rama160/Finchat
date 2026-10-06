import '../../domain/parsing/money_amount_parser.dart';

String formatRupiah(num amount) {
  final digits = amount.abs().round().toString();
  final grouped = digits.replaceAllMapped(RegExp(r'(?=(\d{3})+(?!\d))'), (_) => '.');
  return '${amount < 0 ? "-" : ""}Rp $grouped';
}

/// Canonicalize currency in provider answers without changing non-currency text.
String normalizeRupiahText(String text) => text.replaceAllMapped(
  RegExp(r'\brp\s*\.?\s*(-?\d+(?:[.,]\d+)*)', caseSensitive: false),
  (match) {
    final value = MoneyAmountParser.parse(match[1]!);
    return value == null ? match[0]! : formatRupiah(value);
  },
);
