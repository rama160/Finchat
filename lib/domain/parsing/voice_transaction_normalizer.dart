import 'spoken_money_normalizer.dart';

/// Speech engines sometimes return ungrouped prices, e.g. "bensin 50000".
/// This conversion is restricted to voice input, leaving the text parser intact.
String normalizeVoiceTransactions(String transcript) {
  final text = normalizeSpokenMoney(transcript.replaceAll(RegExp(r'\b(rebu|rebo)\b', caseSensitive: false), 'ribu'));
  return text.replaceAllMapped(RegExp(r'(?<![\w.,/:-])\d{4,}(?![\w.,/:-])'), (m) {
    final prefix = text.substring(0, m.start);
    final suffix = text.substring(m.end);
    if (RegExp(r'\brp\s*$', caseSensitive: false).hasMatch(prefix) ||
        RegExp(r'\b(?:tahun|tanggal|nomor|no)\s*$', caseSensitive: false).hasMatch(prefix) ||
        RegExp(r'^\s*(?:rb|ribu|k|jt|juta|miliar|milyar|rupiah)\b', caseSensitive: false).hasMatch(suffix)) {
      return m[0]!;
    }
    return 'Rp ${m[0]}';
  });
}
