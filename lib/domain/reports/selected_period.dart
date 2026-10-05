enum PeriodKind { day, range, month, all }

class SelectedPeriod {
  SelectedPeriod.range(DateTime first, DateTime last)
      : start = DateTime(first.year, first.month, first.day),
        end = DateTime(last.year, last.month, last.day) {
    if (end!.isBefore(start!)) throw ArgumentError('Rentang tanggal terbalik.');
  }

  SelectedPeriod.day(DateTime date) : this.range(date, date);
  SelectedPeriod.month(int year, int month)
      : this.range(DateTime(year, month), DateTime(year, month + 1, 0));
  const SelectedPeriod.all() : start = null, end = null;

  final DateTime? start;
  final DateTime? end;

  PeriodKind get kind {
    final first = start;
    final last = end;
    if (first == null || last == null) return PeriodKind.all;
    if (first == last) return PeriodKind.day;
    if (first.day == 1 && first.year == last.year &&
        first.month == last.month &&
        last.day == DateTime(first.year, first.month + 1, 0).day) {
      return PeriodKind.month;
    }
    return PeriodKind.range;
  }

  bool contains(DateTime date) => start == null ||
      (!date.isBefore(start!) && date.isBefore(DateTime(end!.year, end!.month, end!.day + 1)));

  SelectedPeriod shift(int direction) {
    if (kind == PeriodKind.all) return this;
    if (kind == PeriodKind.month) return SelectedPeriod.month(start!.year, start!.month + direction);
    final days = DateTime.utc(end!.year, end!.month, end!.day)
        .difference(DateTime.utc(start!.year, start!.month, start!.day)).inDays + 1;
    // Calendar arithmetic preserves boundaries across daylight-saving changes.
    return SelectedPeriod.range(
      DateTime(start!.year, start!.month, start!.day + days * direction),
      DateTime(end!.year, end!.month, end!.day + days * direction),
    );
  }

  String get label => switch (kind) {
    PeriodKind.all => 'Semua tanggal',
    PeriodKind.day => '${weekdays[start!.weekday - 1]}, ${formatDate(start!)}',
    PeriodKind.month => '${months[start!.month - 1]} ${start!.year}',
    PeriodKind.range => '${formatDate(start!)} – ${formatDate(end!)}',
  };

  static const weekdays = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  static const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
  static String formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
}
