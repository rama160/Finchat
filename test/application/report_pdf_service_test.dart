import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:finchat/application/reports/report_pdf_service.dart';
import 'package:finchat/domain/entities/transaction_entity.dart';
import 'package:finchat/domain/reports/report_models.dart';

void main() {
  final service = ReportPdfService();

  ReportSummary report({List<ReportTransactionGroup>? groups}) {
    return ReportSummary(
      start: DateTime(2026, 9, 1),
      endExclusive: DateTime(2026, 10, 1),
      incomeTotal: 1000000,
      expenseTotal: 35000,
      incomeCount: 1,
      expenseCount: 2,
      groups: groups ?? [
        const ReportTransactionGroup(
          type: TransactionType.expense,
          categoryId: 'makanan',
          categoryName: 'Makanan',
          description: 'Nasi Goreng',
          transactionCount: 2,
          totalAmount: 35000,
        ),
      ],
    );
  }

  test('generates a valid PDF document with report content', () async {
    final bytes = await service.generate(
      report: report(),
      reportTitle: 'Laporan Bulanan',
    );

    expect(bytes, isA<Uint8List>());
    expect(bytes.length, greaterThan(100));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('generates a PDF for an empty report', () async {
    final bytes = await service.generate(
      report: report(groups: const []),
      reportTitle: 'Laporan Harian',
    );

    expect(bytes.length, greaterThan(100));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('builds a safe deterministic PDF filename', () {
    expect(
      reportPdfFileName('Laporan Bulanan', DateTime(2026, 9, 1)),
      'laporan_bulanan_20260901.pdf',
    );
  });
}
