import 'package:flutter_test/flutter_test.dart';
import 'package:finchat/domain/reports/selected_period.dart';

void main() {
  test('recognizes one day, arbitrary ranges, full months and leap years', () {
    expect(SelectedPeriod.range(DateTime(2026, 10, 5), DateTime(2026, 10, 5, 23)).kind, PeriodKind.day);
    expect(SelectedPeriod.range(DateTime(2026, 10, 1), DateTime(2026, 10, 30)).kind, PeriodKind.range);
    expect(SelectedPeriod.range(DateTime(2026, 10, 1), DateTime(2026, 10, 31)).kind, PeriodKind.month);
    expect(SelectedPeriod.range(DateTime(2024, 2, 1), DateTime(2024, 2, 29)).kind, PeriodKind.month);
    expect(SelectedPeriod.range(DateTime(2026, 9, 1), DateTime(2026, 10, 31)).kind, PeriodKind.range);
  });
  test('includes the entire last selected day and excludes next day', () {
    final period = SelectedPeriod.month(2026, 10);
    expect(period.contains(DateTime(2026, 10, 31, 23, 59)), isTrue);
    expect(period.contains(DateTime(2026, 11)), isFalse);
    expect(period.contains(DateTime(2026, 9, 30)), isFalse);
    expect(const SelectedPeriod.all().contains(DateTime(2020)), isTrue);
  });
  test('previous and next preserve month boundaries across years', () {
    final period = SelectedPeriod.month(2026, 12).shift(1);
    expect(period.start, DateTime(2027, 1));
    expect(period.end, DateTime(2027, 1, 31));
    expect(SelectedPeriod.month(2024, 3).shift(-1).end, DateTime(2024, 2, 29));
    expect(() => SelectedPeriod.range(DateTime(2026, 10, 6), DateTime(2026, 10, 5)), throwsArgumentError);
  });
}
