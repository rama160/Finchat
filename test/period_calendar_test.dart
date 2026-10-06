import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finchat/domain/reports/selected_period.dart';
import 'package:finchat/presentation/widgets/period_filter.dart';

void main() {
  testWidgets('opening an existing month or year does not silently change its filter', (tester) async {
    for (final period in [SelectedPeriod.month(2026, 10), SelectedPeriod.year(2026)]) {
      SelectedPeriod? selected;
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: PeriodFilter(period: period, onChanged: (value) => selected = value))));
      await tester.tap(find.text(period.label));
      await tester.pumpAndSettle();
      expect(find.text('Min'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Pilih'));
      await tester.pumpAndSettle();
      expect(selected!.start, period.start);
      expect(selected!.end, period.end);
      expect(selected!.kind, period.kind);
    }
  });
  testWidgets('filter opens calendar directly and highlights a selected range', (tester) async {
    SelectedPeriod? selected;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: PeriodFilter(
      period: SelectedPeriod.day(DateTime(2026, 10, 5)), onChanged: (value) => selected = value,
    ))));
    await tester.tap(find.textContaining('05 Oktober 2026'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('calendar_2026_10_6')), findsOneWidget);
    expect(find.text('Min'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('calendar_2026_10_6')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('calendar_2026_10_7')));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Pilih'));
    await tester.pumpAndSettle();
    expect(selected!.start, DateTime(2026, 10, 6));
    expect(selected!.end, DateTime(2026, 10, 7));
  });
  testWidgets('calendar supports a full month and full year', (tester) async {
    SelectedPeriod? selected;
    Future<void> open() async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: PeriodFilter(
        period: SelectedPeriod.day(DateTime(2026, 10, 5)), onChanged: (value) => selected = value,
      ))));
      await tester.tap(find.textContaining('05 Oktober 2026'));
      await tester.pumpAndSettle();
    }
    await open();
    await tester.tap(find.byKey(const ValueKey('calendar_2026_10_1')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('calendar_2026_10_31')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('calendar_2026_10_31')));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Pilih'));
    await tester.pumpAndSettle();
    expect(selected!.kind, PeriodKind.month);
    await open();
    await tester.ensureVisible(find.byKey(const ValueKey('select_whole_year')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('select_whole_year')));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Pilih'));
    await tester.pumpAndSettle();
    expect(selected!.kind, PeriodKind.year);
    expect(selected!.end, DateTime(2026, 12, 31));
    expect(selected!.shift(1).start, DateTime(2027));
  });
}
