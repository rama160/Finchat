import '../../domain/parsing/money_amount_parser.dart';

String formatRupiah(num amount) {
  final digits = amount.abs().round().toString();
  final grouped = digits.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
  return '${amount < 0 ? "-" : ""}Rp $grouped';
}

/// Canonicalize currency in provider answers without changing non-currency text.
String normalizeRupiahText(String text) => text.replaceAllMapped(
  RegExp(r'\brp\s*\.?\s*(-?\s*\.?\s*\d+(?:[.,]\d+)*)', caseSensitive: false),
  (match) {
    final raw = match[1]!.replaceAll(RegExp(r'\s+'), '').replaceFirstMapped(RegExp(r'^(-?)\.'), (m) => m[1]!);
    final value = MoneyAmountParser.parse(raw);
    return value == null ? match[0]! : formatRupiah(value);
  },
);
