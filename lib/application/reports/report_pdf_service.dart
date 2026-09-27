import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/transaction_entity.dart';
import '../../domain/reports/report_models.dart';

class ReportPdfService {
  Future<Uint8List> generate({
    required ReportSummary report,
    required String reportTitle,
  }) async {
    final document = pw.Document(
      title: reportTitle,
      author: 'FinChat',
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (context) => _header(reportTitle),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Halaman ${context.pageNumber} dari ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8),
          ),
        ),
        build: (context) => [
          _period(report),
          pw.SizedBox(height: 12),
          _summary(report),
          pw.SizedBox(height: 18),
          pw.Text(
            'Detail Transaksi',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          if (report.groups.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Text('Tidak ada transaksi pada periode ini.'),
            )
          else
            _details(report.groups),
        ],
      ),
    );

    return document.save();
  }

  pw.Widget _header(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'FinChat',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(title, style: const pw.TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  pw.Widget _period(ReportSummary report) {
    final end = report.endExclusive.subtract(const Duration(days: 1));
    return pw.Text(
      'Periode: ${_date(report.start)} - ${_date(end)}',
      style: const pw.TextStyle(fontSize: 10),
    );
  }

  pw.Widget _summary(ReportSummary report) {
    return pw.Table(
      border: pw.TableBorder.all(width: .5),
      columnWidths: const {
        0: pw.FlexColumnWidth(1),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(1),
        3: pw.FlexColumnWidth(1),
      },
      children: [
        _summaryRow(
          ['Pemasukan', 'Pengeluaran', 'Saldo', 'Jumlah Transaksi'],
          true,
        ),
        _summaryRow(
          [
            _money(report.incomeTotal),
            _money(report.expenseTotal),
            _money(report.balance),
            '${report.transactionCount}',
          ],
          false,
        ),
      ],
    );
  }

  pw.TableRow _summaryRow(List<String> values, bool header) {
    return pw.TableRow(
      children: values
          .map(
            (value) => pw.Padding(
              padding: const pw.EdgeInsets.all(7),
              child: pw.Text(
                value,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: header ? pw.FontWeight.bold : pw.FontWeight.normal,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  pw.Widget _details(List<ReportTransactionGroup> groups) {
    return pw.TableHelper.fromTextArray(
      border: pw.TableBorder.all(width: .5),
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellPadding: const pw.EdgeInsets.all(5),
      headers: const ['Tipe', 'Kategori', 'Detail', 'Jumlah', 'Total'],
      data: groups
          .map(
            (group) => [
              _type(group.type),
              group.categoryName,
              group.description,
              '${group.transactionCount}x',
              _money(group.totalAmount),
            ],
          )
          .toList(),
    );
  }

  static String _type(TransactionType type) => switch (type) {
        TransactionType.income => 'Pemasukan',
        TransactionType.expense => 'Pengeluaran',
      };

  static String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year}';

  static String _money(double value) {
    final negative = value < 0;
    final rounded = value.abs().round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < rounded.length; i++) {
      if (i > 0 && (rounded.length - i) % 3 == 0) buffer.write('.');
      buffer.write(rounded[i]);
    }
    return '${negative ? '-' : ''}Rp ${buffer.toString()}';
  }
}

String reportPdfFileName(String title, DateTime start) {
  final safeTitle = title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  final date = '${start.year.toString().padLeft(4, '0')}'
      '${start.month.toString().padLeft(2, '0')}'
      '${start.day.toString().padLeft(2, '0')}';
  return '${safeTitle}_$date.pdf';
}
