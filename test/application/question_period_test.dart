import 'package:flutter_test/flutter_test.dart';
import 'package:finchat/application/ai/question_period.dart';
import 'package:finchat/domain/reports/selected_period.dart';

void main() {
  final now = DateTime(2026, 10, 5);
  test('questions set their own date scope without a chat filter', () {
    expect(questionPeriod('berapa pengeluaran?', now).kind, PeriodKind.all);
    expect(questionPeriod('pengeluaran kemarin', now).start, DateTime(2026, 10, 4));
    expect(questionPeriod('berapa saldo tahun lalu?', now).start, DateTime(2025));
    expect(questionPeriod('berapa saldo tahun 2024?', now).end, DateTime(2024, 12, 31));
    expect(questionPeriod('pengeluaran 7 hari terakhir', now).start, DateTime(2026, 9, 29));
    expect(questionPeriod('pengeluaran bulan lalu', now).kind, PeriodKind.month);
    expect(questionPeriod('pengeluaran Oktober 2025', now).start, DateTime(2025, 10));
    expect(questionPeriod('pengeluaran 2 Oktober 2026', now).start, DateTime(2026, 10, 2));
  });
  test('full-month question ranges normalize; invalid dates cannot silently select all data', () {
    expect(questionPeriod('pengeluaran 01/10/2026 sampai 31/10/2026', now).kind, PeriodKind.month);
    expect(questionPeriod('pengeluaran 05/10/2026 sampai 07/10/2026', now).end, DateTime(2026, 10, 7));
    expect(() => questionPeriod('pengeluaran 31/02/2026', now), throwsFormatException);
    expect(() => questionPeriod('pengeluaran 07/10/2026 sampai 05/10/2026', now), throwsFormatException);
  });
}
