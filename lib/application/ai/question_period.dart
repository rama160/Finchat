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
  final names = SelectedPeriod.months.map((m) => m.toLowerCase()).join('|');
  final named = RegExp('\\b(?:(\\d{1,2})\\s+)?($names)(?:\\s+(\\d{4}))?\\b').allMatches(q).toList();
  if (named.isNotEmpty) {
    final defaultYear = int.tryParse(named.last[3] ?? '') ?? now.year;
    final dates = <DateTime>[];
    for (final match in named) {
      final month = SelectedPeriod.months.indexWhere((m) => m.toLowerCase() == match[2]) + 1;
      final year = int.tryParse(match[3] ?? '') ?? defaultYear;
      if (match[1] == null) return SelectedPeriod.month(year, month);
      final date = valid(year, month, int.parse(match[1]!));
      if (date == null) throw const FormatException('Tanggal belum valid.');
      dates.add(date);
    }
    if (dates.length == 2) {
      if (dates.last.isBefore(dates.first)) throw const FormatException('Tanggal akhir harus setelah tanggal awal.');
      return SelectedPeriod.range(dates.first, dates.last);
    }
    final shortRange = RegExp(r'\b(\d{1,2})\s+(?:sampai|hingga|–|-)\s+\d{1,2}\s+').firstMatch(q);
    if (shortRange != null) {
      final last = dates.single;
      final first = valid(last.year, last.month, int.parse(shortRange[1]!));
      if (first == null || first.isAfter(last)) throw const FormatException('Rentang tanggal belum valid.');
      return SelectedPeriod.range(first, last);
    }
    if (dates.length == 1) return SelectedPeriod.day(dates.single);
    throw const FormatException('Gunakan satu tanggal atau dua tanggal untuk rentang.');
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
