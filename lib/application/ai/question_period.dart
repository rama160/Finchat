import '../../domain/reports/selected_period.dart';

/// Questions select report data without changing the daily chat history.
SelectedPeriod questionPeriod(String question, DateTime now) {
  final q = question.toLowerCase();
  final explicit = RegExp(r'\b(\d{1,2})[/-](\d{1,2})[/-](\d{4})\b').allMatches(q).toList();
  DateTime? valid(int year, int month, int day) {
    final date = DateTime(year, month, day);
    return year >= 2000 && year <= 2100 && date.year == year && date.month == month && date.day == day ? date : null;
  }
  if (explicit.isNotEmpty) {
    final dates = explicit.map((m) => valid(int.parse(m[3]!), int.parse(m[2]!), int.parse(m[1]!))).toList();
    if (dates.every((d) => d != null)) {
      if (dates.length == 1) return SelectedPeriod.day(dates.single!);
      if (dates.length == 2 && !dates.last!.isBefore(dates.first!)) return SelectedPeriod.range(dates.first!, dates.last!);
    }
    throw const FormatException('Tanggal belum valid. Gunakan tanggal/bulan/tahun, misalnya 05/10/2026.');
  }
  for (var month = 1; month <= 12; month++) {
    final name = SelectedPeriod.months[month - 1].toLowerCase();
    final named = RegExp('\\b(?:(\\d{1,2})\\s+)?$name(?:\\s+(\\d{4}))?\\b').firstMatch(q);
    if (named == null) continue;
    final year = int.tryParse(named[2] ?? '') ?? now.year;
    if (named[1] == null) return SelectedPeriod.month(year, month);
    final date = valid(year, month, int.parse(named[1]!));
    if (date == null) throw const FormatException('Tanggal belum valid.');
    return SelectedPeriod.day(date);
  }
  if (q.contains('semua tanggal') || q.contains('seluruh riwayat') || q.contains('sepanjang waktu')) return const SelectedPeriod.all();
  if (q.contains('hari ini')) return SelectedPeriod.day(now);
  if (q.contains('kemarin')) return SelectedPeriod.day(DateTime(now.year, now.month, now.day - 1));
  if (q.contains('bulan ini')) return SelectedPeriod.month(now.year, now.month);
  if (q.contains('bulan lalu')) return SelectedPeriod.month(now.year, now.month - 1);
  if (q.contains('tahun ini')) return SelectedPeriod.year(now.year);
  if (q.contains('tahun lalu')) return SelectedPeriod.year(now.year - 1);
  final year = RegExp(r'\btahun\s+(20\d{2}|2100)\b').firstMatch(q);
  if (year != null) return SelectedPeriod.year(int.parse(year[1]!));
  if (q.contains('minggu ini') || q.contains('minggu lalu')) {
    final first = DateTime(now.year, now.month, now.day - now.weekday + 1 - (q.contains('minggu lalu') ? 7 : 0));
    return SelectedPeriod.range(first, DateTime(first.year, first.month, first.day + 6));
  }
  final lastDays = RegExp(r'\b(\d{1,3})\s+hari terakhir\b').firstMatch(q);
  if (lastDays != null) {
    final count = int.parse(lastDays[1]!);
    if (count < 1) throw const FormatException('Jumlah hari harus lebih dari nol.');
    return SelectedPeriod.range(DateTime(now.year, now.month, now.day - count + 1), now);
  }
  return const SelectedPeriod.all();
}
